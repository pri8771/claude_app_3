//
//  PuzzleValidator.swift
//  Foldlight
//
//  Verifies that a generated puzzle is genuinely solvable and non-trivial,
//  using the existing engine (no rewrite). Used as a gate by PuzzleGenerator.
//

import Foundation

/// The outcome of validating a puzzle.
enum ValidationResult: Equatable, Sendable {
    /// Solvable and not already solved.
    case valid
    /// No known/working solution reaches the goal.
    case unsolvable
    /// The puzzle is already solved at the start (no folds required).
    case trivial
}

/// Pure puzzle validator. Calls the engine's beam solver + fold replay.
struct PuzzleValidator: Sendable {
    func validate(_ puzzle: Puzzle) -> ValidationResult {
        let initial = puzzle.initialBoard

        // Already solved → trivial.
        if BeamSolver.solve(initial).reachedGoal {
            return .trivial
        }

        // Must have a non-empty solution that actually reaches the goal.
        guard let solution = puzzle.solution, !solution.isEmpty else {
            return .unsolvable
        }
        let solved = FoldEngine.replay(solution, on: initial)
        return BeamSolver.solve(solved).reachedGoal ? .valid : .unsolvable
    }
}
