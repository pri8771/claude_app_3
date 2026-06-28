//
//  FoldEngineTests.swift
//  FoldlightTests
//
//  Fold legality, coordinate mapping, application, overlap and combinations.
//

import XCTest
@testable import Foldlight

final class FoldEngineTests: XCTestCase {
    private func coordinate(_ row: Int, _ column: Int) -> BoardCoordinate {
        BoardCoordinate(row: row, column: column)
    }

    // MARK: Legality

    func testLegalInteriorFolds() {
        let board = Board(width: 4, height: 4)
        XCTAssertTrue(FoldEngine.isLegal(Fold(direction: .bottomOntoTop, position: 0), on: board))
        XCTAssertTrue(FoldEngine.isLegal(Fold(direction: .bottomOntoTop, position: 2), on: board))
        XCTAssertTrue(FoldEngine.isLegal(Fold(direction: .leftOntoRight, position: 1), on: board))
    }

    func testIllegalOutOfRangeFolds() {
        let board = Board(width: 4, height: 4)
        XCTAssertFalse(FoldEngine.isLegal(Fold(direction: .bottomOntoTop, position: -1), on: board))
        XCTAssertFalse(FoldEngine.isLegal(Fold(direction: .bottomOntoTop, position: 3), on: board))
        XCTAssertFalse(FoldEngine.isLegal(Fold(direction: .rightOntoLeft, position: 3), on: board))
    }

    // MARK: Coordinate mapping

    func testReflectedCoordinateHorizontal() {
        let fold = Fold(direction: .bottomOntoTop, position: 0)
        XCTAssertEqual(FoldEngine.reflectedCoordinate(coordinate(1, 2), fold: fold), coordinate(0, 2))
        let fold2 = Fold(direction: .topOntoBottom, position: 1)
        // mirror = 3 → row 0 maps to row 3.
        XCTAssertEqual(FoldEngine.reflectedCoordinate(coordinate(0, 1), fold: fold2), coordinate(3, 1))
    }

    func testReflectedCoordinateVertical() {
        let fold = Fold(direction: .leftOntoRight, position: 1)
        // mirror = 3 → column 0 maps to column 3.
        XCTAssertEqual(FoldEngine.reflectedCoordinate(coordinate(2, 0), fold: fold), coordinate(2, 3))
    }

    func testSourceRegionMembership() {
        XCTAssertTrue(FoldEngine.isSource(coordinate(1, 0), fold: Fold(direction: .bottomOntoTop, position: 0)))
        XCTAssertFalse(FoldEngine.isSource(coordinate(0, 0), fold: Fold(direction: .bottomOntoTop, position: 0)))
        XCTAssertTrue(FoldEngine.isSource(coordinate(0, 0), fold: Fold(direction: .topOntoBottom, position: 0)))
        XCTAssertTrue(FoldEngine.isSource(coordinate(0, 1), fold: Fold(direction: .rightOntoLeft, position: 0)))
    }

    // MARK: Application

    func testApplyFirstFoldProducesSolvedBoard() throws {
        let board = PuzzleFixtures.firstFold.initialBoard
        let fold = try XCTUnwrap(PuzzleFixtures.firstFoldSolution.first)
        let outcome = try XCTUnwrap(FoldEngine.apply(fold, to: board))

        XCTAssertEqual(outcome.board.height, 1)
        XCTAssertEqual(outcome.board.width, 3)
        XCTAssertEqual(outcome.board.effectiveType(at: coordinate(0, 0)), .lightSource)
        XCTAssertEqual(outcome.board.effectiveType(at: coordinate(0, 1)), .path)
        XCTAssertEqual(outcome.board.effectiveType(at: coordinate(0, 2)), .goalCrystal)
        XCTAssertTrue(BeamSolver.solve(outcome.board).reachedGoal)
    }

    func testApplyIllegalFoldReturnsNil() {
        let board = PuzzleFixtures.firstFold.initialBoard
        XCTAssertNil(FoldEngine.apply(Fold(direction: .bottomOntoTop, position: 5), to: board))
    }

    func testOverlapStacksWhenNoCombinationRule() throws {
        // blocker (top) and seed (bottom) have no rule → they stack.
        let board = Board(tiles: [
            [Tile(type: .blocker)],
            [Tile(type: .seed)]
        ])
        let outcome = try XCTUnwrap(FoldEngine.apply(Fold(direction: .bottomOntoTop, position: 0), to: board))
        let cell = outcome.board.cell(at: coordinate(0, 0))
        XCTAssertEqual(cell.layers.count, 2)
        XCTAssertEqual(cell.effectiveType, .seed)
        XCTAssertTrue(outcome.combinations.isEmpty)
    }

    func testCombinationTransformsCell() throws {
        // key folds onto lock → opened gate.
        let board = Board(tiles: [
            [Tile(type: .lock)],
            [Tile(type: .key)]
        ])
        let outcome = try XCTUnwrap(FoldEngine.apply(Fold(direction: .bottomOntoTop, position: 0), to: board))
        XCTAssertEqual(outcome.board.effectiveType(at: coordinate(0, 0)), .openGate)
        XCTAssertEqual(outcome.combinations, [CombinationEvent(coordinate: coordinate(0, 0), result: .openedGate)])
        XCTAssertFalse(outcome.didWin)
    }

    func testWinningCombinationIsDetected() throws {
        // light folds onto goal → win; goal tile retained.
        let board = Board(tiles: [
            [Tile.goal],
            [Tile(type: .lightSource)]
        ])
        let outcome = try XCTUnwrap(FoldEngine.apply(Fold(direction: .bottomOntoTop, position: 0), to: board))
        XCTAssertTrue(outcome.didWin)
        XCTAssertEqual(outcome.board.effectiveType(at: coordinate(0, 0)), .goalCrystal)
    }

    func testReplayIsDeterministic() {
        let board = PuzzleFixtures.firstFold.initialBoard
        let folds = PuzzleFixtures.firstFoldSolution
        let first = FoldEngine.replay(folds, on: board)
        let second = FoldEngine.replay(folds, on: board)
        XCTAssertEqual(first, second)

        // Equal to a single direct application.
        let direct = FoldEngine.apply(folds[0], to: board)?.board
        XCTAssertEqual(first, direct)
    }
}
