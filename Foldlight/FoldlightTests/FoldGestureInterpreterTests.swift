//
//  FoldGestureInterpreterTests.swift
//  FoldlightTests
//
//  The pure gesture→fold mapping used by the SpriteKit board.
//

import XCTest
@testable import Foldlight

final class FoldGestureInterpreterTests: XCTestCase {
    private func interpret(_ gesture: FoldGesture, width: Int = 3, height: Int = 2) -> Fold? {
        FoldGestureInterpreter.fold(for: gesture, boardWidth: width, boardHeight: height, minimumMagnitude: 10)
    }

    func testTooSmallDragProducesNoFold() {
        let gesture = FoldGesture(startCell: BoardCoordinate(row: 1, column: 1), dx: 2, dyDown: -3)
        XCTAssertNil(interpret(gesture))
    }

    func testDragUpFromBottomRowFoldsBottomOntoTop() {
        // Grab the bottom row and pull up → solves PuzzleFixtures.firstFold.
        let gesture = FoldGesture(startCell: BoardCoordinate(row: 1, column: 1), dx: 0, dyDown: -40)
        XCTAssertEqual(interpret(gesture), Fold(direction: .bottomOntoTop, position: 0))
    }

    func testDragDownFromTopRowFoldsTopOntoBottom() {
        let gesture = FoldGesture(startCell: BoardCoordinate(row: 0, column: 0), dx: 0, dyDown: 40)
        XCTAssertEqual(interpret(gesture), Fold(direction: .topOntoBottom, position: 0))
    }

    func testDragRightFoldsLeftOntoRight() {
        let gesture = FoldGesture(startCell: BoardCoordinate(row: 0, column: 1), dx: 50, dyDown: 4)
        XCTAssertEqual(interpret(gesture), Fold(direction: .leftOntoRight, position: 1))
    }

    func testDragLeftFoldsRightOntoLeft() {
        let gesture = FoldGesture(startCell: BoardCoordinate(row: 0, column: 2), dx: -50, dyDown: 0)
        XCTAssertEqual(interpret(gesture), Fold(direction: .rightOntoLeft, position: 1))
    }

    func testPositionsAreClampedToInterior() {
        // Dragging up while grabbing the top row would yield position -1; clamp to 0.
        let gesture = FoldGesture(startCell: BoardCoordinate(row: 0, column: 0), dx: 0, dyDown: -40)
        XCTAssertEqual(interpret(gesture), Fold(direction: .bottomOntoTop, position: 0))
    }

    func testThinBoardCannotFoldAcrossThatAxis() {
        // A 1-row board cannot fold horizontally (vertical drag).
        let gesture = FoldGesture(startCell: BoardCoordinate(row: 0, column: 0), dx: 0, dyDown: -40)
        XCTAssertNil(FoldGestureInterpreter.fold(for: gesture, boardWidth: 3, boardHeight: 1, minimumMagnitude: 10))
    }

    func testGeneratedFoldIsLegalAndSolvesSample() throws {
        let gesture = FoldGesture(startCell: BoardCoordinate(row: 1, column: 1), dx: 0, dyDown: -40)
        let fold = try XCTUnwrap(interpret(gesture))
        var state = PuzzleState(puzzle: PuzzleFixtures.firstFold)
        XCTAssertTrue(state.isLegal(fold))
        XCTAssertTrue(state.apply(fold))
        XCTAssertTrue(state.isSolved)
    }
}
