//
//  PuzzleGenerator.swift
//  Foldlight
//
//  Generates an unlimited supply of verified, solvable puzzles at any difficulty
//  tier, deterministically from a seed (Technical PRD §4).
//
//  Construction note: the engine's fold is destructive (boards shrink, tiles
//  merge), so a literal "apply N folds then invert" is not reversible. Instead we
//  use an equivalent *constructive* reverse-generation that the engine fully
//  supports and that is provably solvable in exactly N folds:
//
//    1. Lay out a solved line on the top row: [L→, path, …, path, G].
//    2. Remove one interior path tile, leaving a gap, and place it N rows below
//       in the same column (all other cells empty).
//    3. The forward solution is N `bottomOntoTop` folds, each lifting the tile up
//       one row until it fills the gap and the beam reaches the goal.
//
//  Difficulty → fold count (Difficulty.foldRange): Easy ≤3, Medium 4–6,
//  Hard 7–9, Expert 10+ (capped at 12 to bound board height).
//

import Foundation

actor PuzzleGenerator {
    private let validator = PuzzleValidator()

    /// Maximum board height we will build (caps Expert fold counts).
    private static let maxFolds = 12

    /// Generate a verified, solvable puzzle for the given difficulty and seed.
    /// Deterministic: the same `(difficulty, seed)` always yields the same puzzle.
    func generate(difficulty: Difficulty, seed: UInt64) async -> Puzzle {
        var rng = SeededGenerator(seed: seed)
        for _ in 0..<5 {
            let candidate = construct(difficulty: difficulty, seed: seed, rng: &rng)
            if validator.validate(candidate) == .valid {
                return candidate
            }
        }
        // Construction is always valid; this is a defensive guaranteed fallback.
        return buildPuzzle(difficulty: difficulty, seed: seed, foldCount: 1, width: 3, gapColumn: 1)
    }

    // MARK: - Construction

    private func construct(difficulty: Difficulty, seed: UInt64, rng: inout SeededGenerator) -> Puzzle {
        let range = difficulty.foldRange
        let upper = min(range.upperBound, Self.maxFolds)
        let lower = min(range.lowerBound, upper)
        let foldCount = Int.random(in: lower...upper, using: &rng)
        let width = Int.random(in: 3...5, using: &rng)
        let gapColumn = Int.random(in: 1...(width - 2), using: &rng)
        return buildPuzzle(difficulty: difficulty, seed: seed, foldCount: foldCount, width: width, gapColumn: gapColumn)
    }

    /// Build a puzzle solvable in exactly `foldCount` folds.
    private func buildPuzzle(difficulty: Difficulty, seed: UInt64, foldCount: Int, width: Int, gapColumn: Int) -> Puzzle {
        let folds = max(1, foldCount)

        // Top row: solved line with a single gap at `gapColumn`.
        var topRow: [Tile?] = []
        topRow.reserveCapacity(width)
        for column in 0..<width {
            if column == 0 {
                topRow.append(Tile.light(facing: .right))
            } else if column == width - 1 {
                topRow.append(Tile.goal)
            } else if column == gapColumn {
                topRow.append(nil) // the gap the player must fill
            } else {
                topRow.append(Tile.path)
            }
        }

        var rows: [[Tile?]] = [topRow]
        // Empty middle rows.
        for _ in 1..<folds {
            rows.append(Array(repeating: nil, count: width))
        }
        // Bottom row carries the displaced path tile in the gap's column.
        var bottomRow: [Tile?] = Array(repeating: nil, count: width)
        bottomRow[gapColumn] = Tile.path
        rows.append(bottomRow)

        let board = Board(tiles: rows)

        // Forward solution: lift the tile one row per fold (crease N-1 … 0).
        let solution = (0..<folds).map { Fold(direction: .bottomOntoTop, position: folds - 1 - $0) }

        let id = "gen-\(seed)-\(difficulty.rawValue)-\(folds)-\(width)-\(gapColumn)"
        return Puzzle(
            id: id,
            title: "\(difficulty.displayName) Puzzle",
            initialBoard: board,
            parFolds: folds,
            solution: solution
        )
    }
}
