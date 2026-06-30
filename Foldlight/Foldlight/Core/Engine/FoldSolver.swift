//
//  FoldSolver.swift
//  Foldlight
//
//  A bounded breadth-first search over the fold space that finds a SHORTEST
//  sequence of folds solving a board, from any state. Because a fold strictly
//  shrinks the board (a region collapses onto another), the search depth is
//  naturally bounded and boards converge quickly. Used for:
//    • robust hints (the next optimal fold from wherever the player is),
//    • true par computation and difficulty scoring,
//    • validating richer generated puzzles are actually solvable.
//
//  Pure and deterministic. Caps on depth and visited nodes keep it bounded even
//  for adversarial inputs (it returns `nil` rather than running away).
//

import Foundation

enum FoldSolver {
    /// Find a shortest fold sequence that solves `board`, or `nil` if none is
    /// found within the search bounds. Returns an empty array if already solved.
    static func solution(for board: Board, maxDepth: Int = 16, nodeLimit: Int = 40_000) -> [Fold]? {
        if BeamSolver.solve(board).reachedGoal { return [] }

        var visited: Set<String> = [stateKey(board)]
        var queue: [(board: Board, path: [Fold])] = [(board, [])]
        var head = 0
        var nodes = 0

        while head < queue.count {
            let (current, path) = queue[head]
            head += 1
            if path.count >= maxDepth { continue }

            for fold in legalFolds(for: current) {
                guard let outcome = FoldEngine.apply(fold, to: current) else { continue }
                nodes += 1
                if nodes > nodeLimit { return nil }

                let next = outcome.board
                if outcome.didWin || BeamSolver.solve(next).reachedGoal {
                    return path + [fold]
                }
                let key = stateKey(next)
                if visited.insert(key).inserted {
                    queue.append((next, path + [fold]))
                }
            }
        }
        return nil
    }

    /// The next single fold that makes progress toward a solution, or `nil`.
    static func nextFold(for board: Board) -> Fold? {
        solution(for: board)?.first
    }

    /// All legal folds for a board, in a stable order.
    static func legalFolds(for board: Board) -> [Fold] {
        var folds: [Fold] = []
        if board.height >= 2 {
            for position in 0...(board.height - 2) {
                folds.append(Fold(direction: .topOntoBottom, position: position))
                folds.append(Fold(direction: .bottomOntoTop, position: position))
            }
        }
        if board.width >= 2 {
            for position in 0...(board.width - 2) {
                folds.append(Fold(direction: .leftOntoRight, position: position))
                folds.append(Fold(direction: .rightOntoLeft, position: position))
            }
        }
        return folds
    }

    /// A compact, beam-equivalent key for a board: dimensions plus each cell's
    /// top tile type and orientation. Deeper layers are ignored because only the
    /// top layer affects the beam, which also collapses bloated layer stacks.
    private static func stateKey(_ board: Board) -> String {
        var key = "\(board.width)x\(board.height)|"
        for row in 0..<board.height {
            for column in 0..<board.width {
                let cell = board.cell(at: BoardCoordinate(row: row, column: column))
                if let tile = cell.top {
                    key += "\(tile.type.rawValue),\(tile.orientation.rawValue);"
                } else {
                    key += "_;"
                }
            }
        }
        return key
    }
}
