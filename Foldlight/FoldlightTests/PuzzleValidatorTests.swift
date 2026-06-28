//
//  PuzzleValidatorTests.swift
//  FoldlightTests
//
//  The solvability/triviality gate used by the generator.
//

import XCTest
@testable import Foldlight

final class PuzzleValidatorTests: XCTestCase {
    private let validator = PuzzleValidator()

    func testValidPuzzlePasses() {
        XCTAssertEqual(validator.validate(PuzzleFixtures.firstFold), .valid)
    }

    func testAlreadySolvedBoardIsTrivial() {
        // A complete line: the beam already reaches the goal with no folds.
        let board = Board(tiles: [[Tile.light(facing: .right), Tile.path, Tile.goal]])
        let puzzle = Puzzle(id: "trivial", title: "Trivial", initialBoard: board, solution: nil)
        XCTAssertEqual(validator.validate(puzzle), .trivial)
    }

    func testMissingSolutionIsUnsolvable() {
        // The fixture board is genuinely unsolved, but without a solution the
        // validator cannot certify it.
        let puzzle = Puzzle(
            id: "nosolution",
            title: "No Solution",
            initialBoard: PuzzleFixtures.firstFold.initialBoard,
            solution: nil
        )
        XCTAssertEqual(validator.validate(puzzle), .unsolvable)
    }

    func testEmptySolutionIsUnsolvable() {
        // An unsolved board with an empty solution cannot be certified.
        let puzzle = Puzzle(
            id: "empty-solution",
            title: "Empty Solution",
            initialBoard: PuzzleFixtures.firstFold.initialBoard,
            solution: []
        )
        XCTAssertEqual(validator.validate(puzzle), .unsolvable)
    }
}
