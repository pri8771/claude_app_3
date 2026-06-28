//
//  PuzzleFixtures.swift
//  FoldlightTests
//
//  Hardcoded puzzle fixtures for tests. These live in the test target only —
//  production paths use the procedural PuzzleGenerator (no hardcoded puzzles).
//

import Foundation
@testable import Foldlight

enum PuzzleFixtures {
    /// A 2×3 puzzle solvable with a single `bottomOntoTop` fold at position 0.
    ///
    /// ```
    /// L . G        L = light source emitting right
    /// . P .        P = path, G = goal crystal
    /// ```
    static var firstFold: Puzzle {
        let board = Board(tiles: [
            [Tile.light(facing: .right), nil, Tile.goal],
            [nil, Tile.path, nil]
        ])
        return Puzzle(
            id: "fixture.firstFold",
            title: "First Light",
            initialBoard: board,
            parFolds: 1,
            solution: firstFoldSolution
        )
    }

    static let firstFoldSolution: [Fold] = [
        Fold(direction: .bottomOntoTop, position: 0)
    ]
}
