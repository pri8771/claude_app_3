//
//  GameRequest.swift
//  Foldlight
//
//  Describes which puzzle the Play screen should load. Set by the Home / Daily /
//  Infinite screens before navigating to Play, then consumed by GameViewModel.
//

import Foundation

/// The source of the next puzzle to play.
enum GameRequest: Equatable, Sendable {
    /// A hand-authored tutorial/vertical-slice level by zero-based index.
    case tutorial(Int)
    /// Today's deterministic daily puzzle (always Medium).
    case daily
    /// An endless generated puzzle starting at the given difficulty tier; the
    /// tier advances after every 3 clears within the session.
    case infinite(Difficulty)
}
