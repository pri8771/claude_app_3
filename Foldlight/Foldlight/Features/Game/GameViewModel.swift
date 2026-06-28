//
//  GameViewModel.swift
//  Foldlight
//
//  The MVVM bridge between the SpriteKit scene and the pure engine. It owns the
//  PuzzleState, loads puzzles from the procedural level system (daily / infinite),
//  applies folds through the engine, and dispatches feedback (haptics + sound).
//  The scene proposes folds; this type decides and applies them. All gameplay
//  rules stay in the engine — never in the scene.
//

import Foundation
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var state: PuzzleState
    /// Set true the moment the puzzle becomes solved, to drive the win overlay.
    @Published private(set) var hasWon = false
    /// Whether the currently loaded puzzle is the daily puzzle.
    @Published private(set) var isDailyPuzzle = false

    /// The SpriteKit scene presented by `GameView`. Created once and reused.
    let scene: BoardScene

    private var environment: AppEnvironment?
    private var didStart = false

    // Infinite-mode session state.
    private var startingDifficulty: Difficulty = .easy
    private var infiniteClears = 0

    init() {
        let placeholder = Puzzle(id: "placeholder", title: "Play", initialBoard: Board(width: 0, height: 0))
        self.state = PuzzleState(puzzle: placeholder)
        self.scene = BoardScene(size: CGSize(width: 390, height: 600))
        configureScene()
        pushStateToScene()
    }

    // MARK: Derived display state

    var moveCount: Int { state.moveCount }
    var canUndo: Bool { state.canUndo }
    var isSolved: Bool { state.isSolved }
    var isLoaded: Bool { state.board.width > 0 }

    var puzzleTitle: String {
        let title = state.puzzle.title
        return title.isEmpty ? "Play" : title
    }

    /// Label for the win-overlay primary action.
    var advanceActionTitle: String { isDailyPuzzle ? "Replay" : "Next Puzzle" }

    var statusText: String {
        guard isLoaded else { return "Loading…" }
        if isSolved {
            return "Solved in \(moveCount) fold\(moveCount == 1 ? "" : "s")!"
        }
        switch state.beam().termination {
        case .blocked, .exitedBoard:
            return "Fold the board to guide the light to the crystal."
        case .noSource:
            return "Preparing puzzle…"
        case .loopGuard:
            return "The beam is looping — fold to redirect it."
        case .reachedGoal:
            return "Solved!"
        }
    }

    // MARK: Lifecycle

    func configure(environment: AppEnvironment) {
        guard self.environment == nil else { return }
        self.environment = environment
    }

    /// Load the requested puzzle (called once from the Play screen's task).
    func start(environment: AppEnvironment) async {
        configure(environment: environment)
        guard !didStart else { return }
        didStart = true
        await load(request: environment.pendingGameRequest, using: environment)
        await environment.analytics.track(.screenViewed("play"))
    }

    private func load(request: GameRequest, using env: AppEnvironment) async {
        switch request {
        case .daily:
            isDailyPuzzle = true
            apply(puzzle: await env.dailyService.today())
        case .infinite(let difficulty):
            isDailyPuzzle = false
            startingDifficulty = difficulty
            infiniteClears = 0
            apply(puzzle: await env.levelRepository.next(difficulty: difficulty))
        }
    }

    private func apply(puzzle: Puzzle) {
        state = PuzzleState(puzzle: puzzle)
        hasWon = false
        pushStateToScene()
    }

    // MARK: Intent

    /// Apply a fold proposed by the scene. Returns whether it was applied.
    @discardableResult
    func proposeFold(_ fold: Fold) -> Bool {
        let oldBoard = state.board
        guard state.isLegal(fold), let outcome = FoldEngine.apply(fold, to: oldBoard) else {
            environment?.haptics.play(.error)
            environment?.audio.play(.invalidFold)
            return false
        }

        state.apply(fold)
        let newBoard = state.board
        let newBeam = state.beam()

        environment?.haptics.play(.mediumImpact)
        environment?.audio.play(.fold)

        scene.animateFold(
            fold,
            from: oldBoard,
            to: newBoard,
            beam: newBeam,
            combinations: outcome.combinations
        ) { [weak self] in
            guard let self else { return }
            if self.state.isSolved {
                self.handleWin()
            }
        }
        return true
    }

    func undo() {
        guard state.undo() else { return }
        hasWon = false
        scene.animateUndo(to: state.board, beam: state.beam())
        environment?.haptics.play(.lightImpact)
    }

    func reset() {
        state.reset()
        hasWon = false
        pushStateToScene()
        environment?.haptics.play(.selection)
    }

    /// Win-overlay primary action: replay (daily) or load the next puzzle
    /// (infinite, advancing difficulty after every 3 clears).
    func advance() {
        if isDailyPuzzle {
            reset()
            return
        }
        guard let env = environment else { return }
        let difficulty = difficultyForClears(infiniteClears)
        Task { @MainActor [weak self] in
            let puzzle = await env.levelRepository.next(difficulty: difficulty)
            self?.apply(puzzle: puzzle)
        }
    }

    // MARK: Helpers

    private func difficultyForClears(_ clears: Int) -> Difficulty {
        let tiers = Difficulty.allCases
        let startIndex = tiers.firstIndex(of: startingDifficulty) ?? 0
        let index = min(startIndex + clears / 3, tiers.count - 1)
        return tiers[index]
    }

    private func handleWin() {
        scene.playWinAnimation()
        environment?.haptics.play(.success)
        environment?.audio.play(.win)
        if !isDailyPuzzle {
            infiniteClears += 1
        }
        if let analytics = environment?.analytics {
            let folds = moveCount
            Task { await analytics.track(AnalyticsEvent("puzzle_complete", parameters: ["folds": "\(folds)"])) }
        }
        // Reveal the celebratory overlay after the ~1.5s win animation plays.
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            self?.hasWon = true
        }
    }

    private func configureScene() {
        scene.onFoldProposed = { [weak self] fold in
            self?.proposeFold(fold) ?? false
        }
        scene.onFoldRejected = { [weak self] in
            _ = self // Feedback is dispatched in proposeFold; nothing extra here.
        }
    }

    private func pushStateToScene() {
        scene.update(board: state.board, beam: state.beam())
    }
}
