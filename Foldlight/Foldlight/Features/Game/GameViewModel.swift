//
//  GameViewModel.swift
//  Foldlight
//
//  The MVVM bridge between the SpriteKit scene and the pure engine. It owns the
//  PuzzleState, applies folds through the engine, and dispatches feedback
//  (haptics + sound hooks). The scene proposes folds; this type decides and
//  applies them. All gameplay rules stay in the engine — never in the scene.
//

import Foundation
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var state: PuzzleState
    /// Set true the moment the puzzle becomes solved, to drive the win overlay.
    @Published private(set) var hasWon = false

    /// The SpriteKit scene presented by `GameView`. Created once and reused.
    let scene: BoardScene

    private var environment: AppEnvironment?

    init(puzzle: Puzzle = SamplePuzzles.firstFold) {
        self.state = PuzzleState(puzzle: puzzle)
        self.scene = BoardScene(size: CGSize(width: 390, height: 600))
        configureScene()
        pushStateToScene()
    }

    // MARK: Derived display state

    var moveCount: Int { state.moveCount }
    var canUndo: Bool { state.canUndo }
    var isSolved: Bool { state.isSolved }
    var puzzleTitle: String { state.puzzle.title }

    var statusText: String {
        if isSolved {
            return "Solved in \(moveCount) fold\(moveCount == 1 ? "" : "s")!"
        }
        switch state.beam().termination {
        case .blocked, .exitedBoard:
            return "Fold the board to guide the light to the crystal."
        case .noSource:
            return "No light source on this board."
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

    func onAppear() {
        guard let analytics = environment?.analytics else { return }
        Task { await analytics.track(.screenViewed("play")) }
    }

    // MARK: Intent

    /// Apply a fold proposed by the scene. Returns whether it was applied.
    @discardableResult
    func proposeFold(_ fold: Fold) -> Bool {
        let oldBoard = state.board
        guard state.isLegal(fold), let outcome = FoldEngine.apply(fold, to: oldBoard) else {
            // Illegal: error haptic + sound; the scene shows the red flash.
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

    /// Debug affordance: reload the hardcoded test puzzle.
    func loadDebugPuzzle() {
        state = PuzzleState(puzzle: SamplePuzzles.firstFold)
        hasWon = false
        pushStateToScene()
    }

    // MARK: Helpers

    private func handleWin() {
        scene.playWinAnimation()
        environment?.haptics.play(.success)
        environment?.audio.play(.win)
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
            // Haptics/sound are already played in proposeFold; nothing extra here.
            _ = self
        }
    }

    private func pushStateToScene() {
        scene.update(board: state.board, beam: state.beam())
    }
}
