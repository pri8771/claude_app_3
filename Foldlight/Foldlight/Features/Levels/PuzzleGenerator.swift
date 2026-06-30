//
//  PuzzleGenerator.swift
//  Foldlight
//
//  Generates an unlimited supply of verified, solvable puzzles at any difficulty
//  tier, deterministically from a seed (Technical PRD §4).
//
//  Construction note: the engine's fold is destructive (boards shrink, tiles
//  merge), so a literal "apply N folds then invert" is not reversible. Instead we
//  build candidate boards from a small library of *templates* — straight light
//  lines broken in any of the four fold directions, plus mirror-bend L-shapes —
//  each paired with an explicitly DESIGNED solution of the tier's fold length.
//  Every candidate is verified against the real engine (the designed solution
//  must actually drive the beam to the goal) before it ships, so all puzzles are
//  guaranteed solvable with an honest, tier-appropriate par.
//
//  Difficulty → fold count (Difficulty.foldRange): Easy ≤3, Medium 4–6,
//  Hard 7–9, Expert 10+ (capped at 12 to bound board size).
//

import Foundation

actor PuzzleGenerator {
    private let validator = PuzzleValidator()

    /// Maximum fold distance we will build (caps Expert board size).
    private static let maxFolds = 12

    /// Generate a verified, solvable puzzle for the given difficulty and seed.
    /// Deterministic: the same `(difficulty, seed)` always yields the same puzzle.
    func generate(difficulty: Difficulty, seed: UInt64) async -> Puzzle {
        var rng = SeededGenerator(seed: seed)
        let range = difficulty.foldRange
        let upper = min(range.upperBound, Self.maxFolds)
        let lower = min(range.lowerBound, upper)

        for attempt in 0..<28 {
            guard let candidate = construct(difficulty: difficulty, attempt: attempt, lower: lower, upper: upper, rng: &rng) else { continue }
            guard candidate.solution.count >= lower, candidate.solution.count <= upper else { continue }

            let puzzle = Puzzle(
                id: candidate.id,
                title: difficulty.displayName,
                initialBoard: candidate.board,
                parFolds: candidate.solution.count,
                solution: candidate.solution
            )
            if validator.validate(puzzle) == .valid {
                return puzzle
            }
        }
        // Guaranteed fallback: the canonical bottom-onto-top linear shape.
        return buildFallback(difficulty: difficulty, seed: seed, foldCount: max(1, lower))
    }

    // MARK: - Template selection

    private struct Candidate { let board: Board; let id: String; let solution: [Fold] }

    private func construct(difficulty: Difficulty, attempt: Int, lower: Int, upper: Int, rng: inout SeededGenerator) -> Candidate? {
        let foldCount = Int.random(in: lower...upper, using: &rng)

        // Mirror-bend puzzles unlock at Medium+ and appear ~40% of the time.
        let allowMirror = difficulty != .easy
        let useMirror = allowMirror && Int.random(in: 0...9, using: &rng) < 4 && foldCount >= 2

        if useMirror, let mirror = buildMirrorBend(difficulty: difficulty, attempt: attempt, foldCount: foldCount, rng: &rng) {
            return mirror
        }
        return buildLinear(difficulty: difficulty, attempt: attempt, foldCount: foldCount, rng: &rng)
    }

    // MARK: - Linear templates (all four fold directions)

    /// A straight light line broken by a single displaced tile. Built in two
    /// clean orientations — a rightward beam folded up (`bottomOntoTop`) or a
    /// downward beam folded in from the right (`rightOntoLeft`) — so the player
    /// exercises both fold axes and both beam directions.
    private func buildLinear(difficulty: Difficulty, attempt: Int, foldCount: Int, rng: inout SeededGenerator) -> Candidate? {
        let folds = max(1, min(foldCount, Self.maxFolds))
        let vertical = Bool.random(using: &rng) // a vertical (downward) beam vs horizontal
        let lineLength = Int.random(in: 3...5, using: &rng)
        let gapIndex = Int.random(in: 1...(lineLength - 2), using: &rng)
        let span = folds + 1

        let board: Board
        let direction: FoldDirection
        if vertical {
            // Vertical light line in column 0; displaced tile sits `span` columns right.
            direction = .rightOntoLeft
            let height = lineLength
            let width = span
            var tiles = emptyGrid(width: width, height: height)
            for row in 0..<height {
                tiles[row][0] = verticalLineTile(row: row, height: height, gapRow: gapIndex)
            }
            tiles[gapIndex][width - 1] = Tile.path
            board = Board(tiles: tiles)
        } else {
            // Horizontal light line in row 0; displaced tile sits `span` rows below.
            direction = .bottomOntoTop
            let width = lineLength
            let height = span
            var tiles = emptyGrid(width: width, height: height)
            tiles[0] = horizontalLine(width: width, gapColumn: gapIndex)
            tiles[height - 1][gapIndex] = Tile.path
            board = Board(tiles: tiles)
        }

        guard let solution = verifiedRun(on: board, direction: direction, foldCount: folds) else { return nil }
        return Candidate(board: board, id: "lin-\(difficulty.rawValue)-\(attempt)-\(direction)-\(folds)-\(lineLength)-\(gapIndex)", solution: solution)
    }

    // MARK: - Mirror-bend template

    /// An L-shaped beam: the light travels right into a mirror, turns down to the
    /// goal. One tile of the vertical leg is displaced and restored by folding.
    private func buildMirrorBend(difficulty: Difficulty, attempt: Int, foldCount: Int, rng: inout SeededGenerator) -> Candidate? {
        let folds = max(2, min(foldCount, Self.maxFolds))
        let horizontalLength = Int.random(in: 2...4, using: &rng)
        let mirrorColumn = horizontalLength - 1
        let width = horizontalLength
        let gapRow = 1
        let displacedRow = gapRow + folds
        let height = displacedRow + 1

        var tiles = emptyGrid(width: width, height: height)
        tiles[0][0] = Tile.light(facing: .right)
        for column in 1..<mirrorColumn {
            tiles[0][column] = Tile.path
        }
        tiles[0][mirrorColumn] = Tile.mirror(.deg90) // back-slash: right -> down
        tiles[height - 1][mirrorColumn] = Tile.goal
        // Vertical leg above the displaced tile (rows gapRow+1 ..< displacedRow are
        // path; the gap at gapRow is what the displaced tile fills).
        for row in (gapRow + 1)..<displacedRow {
            tiles[row][mirrorColumn] = Tile.path
        }
        tiles[displacedRow][mirrorColumn] = Tile.path

        let board = Board(tiles: tiles)
        // Designed solution: lift the displaced tile up one row per fold.
        let solution = (0..<folds).map { Fold(direction: .bottomOntoTop, position: displacedRow - 1 - $0) }
        guard strictlySolves(solution, on: board) else { return nil }
        return Candidate(board: board, id: "mir-\(difficulty.rawValue)-\(attempt)-\(folds)-\(width)x\(height)", solution: solution)
    }

    // MARK: - Designed-solution helpers

    /// Try the two natural single-direction position runs (descending, ascending)
    /// for a linear template and return the first that the engine confirms solves
    /// the board with every fold legal in sequence.
    private func verifiedRun(on board: Board, direction: FoldDirection, foldCount: Int) -> [Fold]? {
        let descending = (0..<foldCount).map { Fold(direction: direction, position: foldCount - 1 - $0) }
        let ascending = (0..<foldCount).map { Fold(direction: direction, position: $0) }
        for run in [descending, ascending] where strictlySolves(run, on: board) {
            return run
        }
        return nil
    }

    /// Whether applying every fold in order is legal and ends with the beam at the
    /// goal (or a winning overlap). Stricter than `FoldEngine.replay`, which would
    /// silently skip illegal folds.
    private func strictlySolves(_ folds: [Fold], on board: Board) -> Bool {
        var current = board
        for fold in folds {
            guard let outcome = FoldEngine.apply(fold, to: current) else { return false }
            current = outcome.board
            if outcome.didWin { return true }
        }
        return BeamSolver.solve(current).reachedGoal
    }

    // MARK: - Grid helpers

    private func emptyGrid(width: Int, height: Int) -> [[Tile?]] {
        Array(repeating: Array(repeating: nil, count: width), count: height)
    }

    private func horizontalLine(width: Int, gapColumn: Int) -> [Tile?] {
        var row: [Tile?] = []
        row.reserveCapacity(width)
        for column in 0..<width {
            if column == 0 {
                row.append(Tile.light(facing: .right))
            } else if column == width - 1 {
                row.append(Tile.goal)
            } else if column == gapColumn {
                row.append(nil)
            } else {
                row.append(Tile.path)
            }
        }
        return row
    }

    private func verticalLineTile(row: Int, height: Int, gapRow: Int) -> Tile? {
        if row == 0 { return Tile.light(facing: .down) }
        if row == height - 1 { return Tile.goal }
        if row == gapRow { return nil }
        return Tile.path
    }

    // MARK: - Fallback

    private func buildFallback(difficulty: Difficulty, seed: UInt64, foldCount: Int) -> Puzzle {
        let folds = max(1, foldCount)
        let width = 3
        let gapColumn = 1
        var tiles = emptyGrid(width: width, height: folds + 1)
        tiles[0] = horizontalLine(width: width, gapColumn: gapColumn)
        tiles[folds][gapColumn] = Tile.path
        let board = Board(tiles: tiles)
        let solution = (0..<folds).map { Fold(direction: .bottomOntoTop, position: folds - 1 - $0) }
        return Puzzle(
            id: "gen-fallback-\(seed)-\(difficulty.rawValue)-\(folds)",
            title: difficulty.displayName,
            initialBoard: board,
            parFolds: solution.count,
            solution: solution
        )
    }
}
