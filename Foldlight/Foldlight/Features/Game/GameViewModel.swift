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
    private enum PlayMode: Equatable {
        case tutorial(Int)
        case daily
        case infinite
    }

    @Published private(set) var state: PuzzleState
    /// Set true the moment the puzzle becomes solved, to drive the win overlay.
    @Published private(set) var hasWon = false
    /// Whether the currently loaded puzzle is the daily puzzle.
    @Published private(set) var isDailyPuzzle = false
    /// The reward summary for the most recent solve, shown on the win screen.
    @Published private(set) var lastSummary: CompletionSummary?
    /// Number of hints used on the current puzzle.
    @Published private(set) var hintsUsed = 0

    /// The SpriteKit scene presented by `GameView`. Created once and reused.
    let scene: BoardScene

    private var environment: AppEnvironment?
    private var didStart = false

    // Infinite-mode session state.
    private var mode: PlayMode = .infinite
    private var startingDifficulty: Difficulty = .easy
    private var infiniteClears = 0
    /// Difficulty of the currently loaded puzzle (drives reward scaling).
    private var currentDifficulty: Difficulty = .easy
    /// Pending win-overlay reveal; cancelled if the player undoes/resets first.
    private var winRevealTask: Task<Void, Never>?

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
    var advanceActionTitle: String {
        switch mode {
        case .daily:
            return "Replay"
        case .tutorial(let index):
            return TutorialPuzzles.nextIndex(after: index) == nil ? "Start Infinite" : "Next Level"
        case .infinite:
            return "Next Puzzle"
        }
    }

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
        scene.reduceMotion = environment.settings.reduceMotion
        scene.theme = BoardTheme.forBiome(environment.profile.currentBiome)
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
        case .tutorial(let index):
            isDailyPuzzle = false
            guard let level = TutorialPuzzles.level(at: index) ?? TutorialPuzzles.level(at: 0) else { return }
            mode = .tutorial(level.index)
            currentDifficulty = level.difficulty
            apply(puzzle: level.puzzle)
        case .daily:
            isDailyPuzzle = true
            mode = .daily
            currentDifficulty = .medium
            apply(puzzle: await env.dailyService.today())
        case .infinite(let difficulty):
            isDailyPuzzle = false
            mode = .infinite
            startingDifficulty = difficulty
            currentDifficulty = difficulty
            infiniteClears = 0
            apply(puzzle: await env.levelRepository.next(difficulty: difficulty))
        }
    }

    private func apply(puzzle: Puzzle) {
        winRevealTask?.cancel()
        winRevealTask = nil
        state = PuzzleState(puzzle: puzzle)
        hasWon = false
        lastSummary = nil
        hintsUsed = 0
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
        cancelPendingWin()
        scene.animateUndo(to: state.board, beam: state.beam())
        environment?.haptics.play(.lightImpact)
    }

    func reset() {
        state.reset()
        cancelPendingWin()
        pushStateToScene()
        environment?.haptics.play(.selection)
    }

    /// Cancel a queued win-overlay reveal and hide the overlay. Called whenever
    /// the board changes out from under a pending win (undo / reset).
    private func cancelPendingWin() {
        winRevealTask?.cancel()
        winRevealTask = nil
        hasWon = false
    }

    /// Whether a hint can be offered right now.
    var canHint: Bool { isLoaded && !isSolved && !hasWon }

    /// Surface the next optimal fold on the board, computed live from the current
    /// state so it is correct even after the player has diverged from par.
    func requestHint() {
        guard canHint, let fold = FoldSolver.nextFold(for: state.board) else {
            environment?.haptics.play(.error)
            return
        }
        guard let environment else { return }

        Task { @MainActor [weak self] in
            guard let self else { return }
            guard await environment.consumeHintCredit() else {
                environment.haptics.play(.error)
                return
            }
            self.hintsUsed += 1
            self.scene.showHint(fold)
            environment.haptics.play(.lightImpact)
            await environment.analytics.track(AnalyticsEvent("hint_used", parameters: ["puzzle": self.state.puzzle.id]))
        }
    }

    /// Win-overlay primary action: replay (daily) or load the next puzzle
    /// (infinite, advancing difficulty after every 3 clears).
    func advance() {
        switch mode {
        case .daily:
            reset()
            return
        case .tutorial(let index):
            if let next = TutorialPuzzles.nextIndex(after: index), let level = TutorialPuzzles.level(at: next) {
                mode = .tutorial(next)
                currentDifficulty = level.difficulty
                apply(puzzle: level.puzzle)
                return
            }
            guard let env = environment else { return }
            mode = .infinite
            startingDifficulty = .easy
            currentDifficulty = .easy
            infiniteClears = 0
            Task { @MainActor [weak self] in
                let puzzle = await env.levelRepository.next(difficulty: .easy)
                self?.apply(puzzle: puzzle)
            }
        case .infinite:
            guard let env = environment else { return }
            let difficulty = difficultyForClears(infiniteClears)
            currentDifficulty = difficulty
            Task { @MainActor [weak self] in
                let puzzle = await env.levelRepository.next(difficulty: difficulty)
                self?.apply(puzzle: puzzle)
            }
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

        let folds = moveCount
        let par = state.puzzle.parFolds
        let daily = isDailyPuzzle
        let difficulty = currentDifficulty
        let puzzleID = state.puzzle.id
        let rewardsRepeatable = mode == .infinite

        // One task owns the whole win flow: award the reward immediately (so it
        // is tied to the solve, not the overlay), then reveal the overlay after
        // the ~1.4s celebration — unless an undo/reset cancelled it first.
        winRevealTask?.cancel()
        winRevealTask = Task { @MainActor [weak self] in
            guard let self, let env = self.environment else { return }

            let summary = await env.recordCompletion(
                moveCount: folds,
                parFolds: par,
                difficulty: difficulty,
                isDaily: daily,
                puzzleID: puzzleID,
                rewardsRepeatable: rewardsRepeatable
            )
            if Task.isCancelled { return }
            self.lastSummary = summary
            if self.mode == .infinite { self.infiniteClears += 1 }

            await env.analytics.track(AnalyticsEvent(
                "puzzle_complete",
                parameters: ["folds": "\(folds)", "stars": "\(summary.stars)", "fragments": "\(summary.fragmentsEarned)"]
            ))

            try? await Task.sleep(nanoseconds: 1_400_000_000)
            guard !Task.isCancelled, self.state.isSolved else { return }
            self.hasWon = true
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
