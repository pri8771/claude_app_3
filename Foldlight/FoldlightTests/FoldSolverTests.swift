//
//  FoldSolverTests.swift
//  FoldlightTests
//
//  The bounded BFS solver that powers hints and par: it must find a solving fold
//  sequence from any state, report already-solved boards, and give up cleanly on
//  the unsolvable.
//

import XCTest
@testable import Foldlight

final class FoldSolverTests: XCTestCase {
    /// A light line broken by one displaced tile, solvable by folding it up.
    private func brokenLineBoard() -> Board {
        Board(tiles: [
            [Tile.light(facing: .right), nil, Tile.goal],
            [nil, Tile.path, nil]
        ])
    }

    func testFindsSolutionThatReachesGoal() {
        let board = brokenLineBoard()
        guard let solution = FoldSolver.solution(for: board) else {
            return XCTFail("expected a solution")
        }
        XCTAssertFalse(solution.isEmpty)
        let solved = FoldEngine.replay(solution, on: board)
        XCTAssertTrue(BeamSolver.solve(solved).reachedGoal)
    }

    func testSolutionIsShortest() {
        // This board is reachable in a single fold; BFS must not return a longer one.
        let board = brokenLineBoard()
        let solution = FoldSolver.solution(for: board)
        XCTAssertEqual(solution?.count, 1)
    }

    func testNextFoldMatchesSolutionHead() {
        let board = brokenLineBoard()
        XCTAssertEqual(FoldSolver.nextFold(for: board), FoldSolver.solution(for: board)?.first)
    }

    func testAlreadySolvedReturnsEmpty() {
        let board = Board(tiles: [[Tile.light(facing: .right), Tile.goal]])
        XCTAssertEqual(FoldSolver.solution(for: board), [])
    }

    func testUnsolvableReturnsNil() {
        // A 1×1 board with only a light source: no goal, no legal folds.
        let board = Board(tiles: [[Tile.light(facing: .right)]])
        XCTAssertNil(FoldSolver.solution(for: board))
    }
}
