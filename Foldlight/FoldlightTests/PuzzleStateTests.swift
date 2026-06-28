//
//  PuzzleStateTests.swift
//  FoldlightTests
//
//  Play-session state: solving a hardcoded puzzle through engine calls, undo,
//  reset, illegal-fold safety, and serialization.
//

import XCTest
@testable import Foldlight

final class PuzzleStateTests: XCTestCase {
    func testInitialStateIsUnsolved() {
        let state = PuzzleState(puzzle: PuzzleFixtures.firstFold)
        XCTAssertFalse(state.isSolved)
        XCTAssertEqual(state.moveCount, 0)
        XCTAssertFalse(state.canUndo)
    }

    func testHardcodedPuzzleSolvesThroughEngineCalls() throws {
        var state = PuzzleState(puzzle: PuzzleFixtures.firstFold)
        let fold = try XCTUnwrap(PuzzleFixtures.firstFoldSolution.first)

        XCTAssertTrue(state.apply(fold))
        XCTAssertTrue(state.isSolved)
        XCTAssertEqual(state.moveCount, 1)
        XCTAssertTrue(state.canUndo)
        XCTAssertTrue(state.result().isSolved)
    }

    func testUndoRestoresPreviousBoard() throws {
        var state = PuzzleState(puzzle: PuzzleFixtures.firstFold)
        let initialBoard = state.board
        let fold = try XCTUnwrap(PuzzleFixtures.firstFoldSolution.first)

        state.apply(fold)
        XCTAssertTrue(state.undo())
        XCTAssertEqual(state.board, initialBoard)
        XCTAssertEqual(state.moveCount, 0)
        XCTAssertFalse(state.isSolved)
        XCTAssertFalse(state.canUndo)
    }

    func testResetReturnsToInitial() throws {
        var state = PuzzleState(puzzle: PuzzleFixtures.firstFold)
        let initialBoard = state.board
        let fold = try XCTUnwrap(PuzzleFixtures.firstFoldSolution.first)

        state.apply(fold)
        state.reset()
        XCTAssertEqual(state.board, initialBoard)
        XCTAssertEqual(state.moveCount, 0)
        XCTAssertFalse(state.isSolved)
    }

    func testIllegalFoldLeavesStateUnchanged() {
        var state = PuzzleState(puzzle: PuzzleFixtures.firstFold)
        let before = state.board
        XCTAssertFalse(state.apply(Fold(direction: .bottomOntoTop, position: 9)))
        XCTAssertEqual(state.board, before)
        XCTAssertEqual(state.moveCount, 0)
    }

    func testMultipleFoldsAndStepwiseUndo() {
        let puzzle = Puzzle(id: "t.empty", title: "Empty", initialBoard: Board(width: 1, height: 4))
        var state = PuzzleState(puzzle: puzzle)
        let initial = state.board

        XCTAssertTrue(state.apply(Fold(direction: .bottomOntoTop, position: 2)))
        XCTAssertTrue(state.apply(Fold(direction: .bottomOntoTop, position: 1)))
        XCTAssertEqual(state.moveCount, 2)

        XCTAssertTrue(state.undo())
        XCTAssertEqual(state.moveCount, 1)
        XCTAssertTrue(state.undo())
        XCTAssertEqual(state.moveCount, 0)
        XCTAssertEqual(state.board, initial)
    }

    func testDeterministicReplayMatchesInteractivePlay() throws {
        var state = PuzzleState(puzzle: PuzzleFixtures.firstFold)
        for fold in PuzzleFixtures.firstFoldSolution {
            state.apply(fold)
        }
        let replayed = FoldEngine.replay(PuzzleFixtures.firstFoldSolution, on: PuzzleFixtures.firstFold.initialBoard)
        XCTAssertEqual(state.board, replayed)
    }

    func testPuzzleSerializationRoundTrip() throws {
        let puzzle = PuzzleFixtures.firstFold
        let data = try JSONEncoder().encode(puzzle)
        let decoded = try JSONDecoder().decode(Puzzle.self, from: data)
        XCTAssertEqual(decoded, puzzle)
    }
}
