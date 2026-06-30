//
//  FoldEngine.swift
//  Foldlight
//
//  Core engine. Applies folds to a board: detects legal folds, mirror-transforms
//  the source region onto the target region, resolves overlapping tiles via the
//  combination matrix, and recomputes the board bounds (Technical PRD §3.2).
//
//  All functions are pure — they take a board and return a new board, never
//  mutating shared state — which makes fold replay fully deterministic.
//

import Foundation

/// A tile combination that occurred at a coordinate during a fold.
struct CombinationEvent: Equatable, Sendable {
    let coordinate: BoardCoordinate
    let result: CombinationResult
}

/// The result of applying a fold: the new board and any combinations triggered.
struct FoldOutcome: Equatable, Sendable {
    let board: Board
    let combinations: [CombinationEvent]

    /// Whether any combination immediately won the puzzle.
    var didWin: Bool { combinations.contains { $0.result.isWin } }
}

/// Pure fold operations.
enum FoldEngine {
    // MARK: - Legality

    /// Whether a fold's crease is interior to the board, so both the source and
    /// target regions are non-empty.
    static func isLegal(_ fold: Fold, on board: Board) -> Bool {
        switch fold.direction.axis {
        case .horizontal:
            return fold.position >= 0 && fold.position <= board.height - 2
        case .vertical:
            return fold.position >= 0 && fold.position <= board.width - 2
        }
    }

    // MARK: - Coordinate mapping

    /// Whether a coordinate is part of the moving (source) region of a fold.
    static func isSource(_ coordinate: BoardCoordinate, fold: Fold) -> Bool {
        switch fold.direction {
        case .topOntoBottom: return coordinate.row <= fold.position
        case .bottomOntoTop: return coordinate.row > fold.position
        case .leftOntoRight: return coordinate.column <= fold.position
        case .rightOntoLeft: return coordinate.column > fold.position
        }
    }

    /// The mirror-transformed coordinate of a source cell across the crease.
    static func reflectedCoordinate(_ coordinate: BoardCoordinate, fold: Fold) -> BoardCoordinate {
        let mirror = 2 * fold.position + 1
        switch fold.direction.axis {
        case .horizontal:
            return BoardCoordinate(row: mirror - coordinate.row, column: coordinate.column)
        case .vertical:
            return BoardCoordinate(row: coordinate.row, column: mirror - coordinate.column)
        }
    }

    // MARK: - Application

    /// Apply a fold, returning the new board and combination events, or `nil`
    /// if the fold is illegal.
    static func apply(_ fold: Fold, to board: Board) -> FoldOutcome? {
        guard isLegal(fold, on: board) else { return nil }

        // 1. Compute the destination of every cell and the resulting bounds.
        func destination(of coordinate: BoardCoordinate) -> BoardCoordinate {
            isSource(coordinate, fold: fold) ? reflectedCoordinate(coordinate, fold: fold) : coordinate
        }

        var minRow = Int.max, maxRow = Int.min, minColumn = Int.max, maxColumn = Int.min
        for coordinate in board.coordinates {
            let target = destination(of: coordinate)
            minRow = min(minRow, target.row)
            maxRow = max(maxRow, target.row)
            minColumn = min(minColumn, target.column)
            maxColumn = max(maxColumn, target.column)
        }

        let newHeight = maxRow - minRow + 1
        let newWidth = maxColumn - minColumn + 1
        func normalized(_ coordinate: BoardCoordinate) -> BoardCoordinate {
            BoardCoordinate(row: coordinate.row - minRow, column: coordinate.column - minColumn)
        }

        var cells = Array(repeating: Array(repeating: Cell.empty, count: newWidth), count: newHeight)

        // 2. Place the stationary (target) region first.
        for coordinate in board.coordinates where !isSource(coordinate, fold: fold) {
            let nc = normalized(coordinate)
            cells[nc.row][nc.column] = board.cell(at: coordinate)
        }

        // 3. Fold the source region on top, resolving combinations.
        var events: [CombinationEvent] = []
        for coordinate in board.coordinates where isSource(coordinate, fold: fold) {
            let sourceCell = board.cell(at: coordinate)
            guard !sourceCell.isEmpty else { continue }
            let nc = normalized(reflectedCoordinate(coordinate, fold: fold))
            let merged = merge(existing: cells[nc.row][nc.column], incoming: sourceCell, at: nc)
            cells[nc.row][nc.column] = merged.cell
            if let event = merged.event { events.append(event) }
        }

        let newBoard = Board(width: newWidth, height: newHeight, cells: cells)
        return FoldOutcome(board: newBoard, combinations: events)
    }

    /// Replay a sequence of folds from a starting board. Illegal folds in the
    /// sequence are skipped, so replay always terminates with a valid board.
    static func replay(_ folds: [Fold], on board: Board) -> Board {
        var current = board
        for fold in folds {
            if let outcome = apply(fold, to: current) {
                current = outcome.board
            }
        }
        return current
    }

    // MARK: - Overlap resolution

    /// Merge an incoming (folded) cell onto an existing cell.
    private static func merge(
        existing: Cell,
        incoming: Cell,
        at coordinate: BoardCoordinate
    ) -> (cell: Cell, event: CombinationEvent?) {
        guard let existingTop = existing.top else {
            // Target empty: the folded tile simply moves in.
            return (incoming, nil)
        }
        guard let incomingTop = incoming.top else {
            return (existing, nil)
        }

        if let result = CombinationMatrix.result(existingTop.type, incomingTop.type) {
            let event = CombinationEvent(coordinate: coordinate, result: result)
            if let type = result.resultingType {
                return (Cell(Tile(type: type)), event)
            }
            // Winning overlap (lightSource + goalCrystal): deterministically retain
            // the goal crystal regardless of which region it folded from, so the
            // solved board still contains a goalCrystal and any post-win beam or
            // undo/replay recompute stays consistent with the win flag.
            let goalCell = existingTop.type == .goalCrystal ? existing : incoming
            return (goalCell, event)
        }

        // No combination rule: tiles stack as layers (overlap representation).
        // Only the top layer is beam-relevant, so cap the stack depth to bound
        // memory and serialization size across deep fold/undo histories.
        let stacked = existing.layers + incoming.layers
        let capped = stacked.count > Cell.maxLayers ? Array(stacked.suffix(Cell.maxLayers)) : stacked
        return (Cell(layers: capped), nil)
    }
}
