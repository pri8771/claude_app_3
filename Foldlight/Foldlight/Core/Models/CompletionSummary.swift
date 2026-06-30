//
//  CompletionSummary.swift
//  Foldlight
//
//  The result of completing a puzzle: what the player earned and their updated
//  standing. Produced by `Progression.record` and surfaced on the
//  level-complete screen. A pure value type so it stays testable.
//

import Foundation

/// A summary of one solved puzzle, used to drive the level-complete screen and
/// any reward feedback.
struct CompletionSummary: Equatable, Sendable {
    /// Light Fragments awarded for this solve (0 when re-playing a daily already
    /// completed today).
    let fragmentsEarned: Int
    /// Star rating earned, 1–3, scored against the puzzle's par fold count.
    let stars: Int
    /// Fold count used to solve.
    let moveCount: Int
    /// Optimal (par) fold count, when known.
    let parFolds: Int?
    /// Whether this completion counted as a fresh reward (false on a daily replay).
    let didReward: Bool
    /// Whether this was the daily puzzle.
    let isDaily: Bool
    /// The player's daily streak after this completion.
    let streak: Int
    /// The player's running total of completed levels after this completion.
    let totalLevelsCompleted: Int

    /// A new, empty summary (used as an initial value).
    static let none = CompletionSummary(
        fragmentsEarned: 0, stars: 0, moveCount: 0, parFolds: nil,
        didReward: false, isDaily: false, streak: 0, totalLevelsCompleted: 0
    )
}
