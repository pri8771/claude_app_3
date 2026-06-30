//
//  TutorialPuzzlesTests.swift
//  FoldlightTests
//
//  Verifies the five guided vertical-slice levels remain solvable and teachable.
//

import XCTest
@testable import Foldlight

final class TutorialPuzzlesTests: XCTestCase {
    private let validator = PuzzleValidator()

    func testTutorialSetHasFiveLevels() {
        XCTAssertEqual(TutorialPuzzles.count, 5)
        XCTAssertEqual(TutorialPuzzles.level(at: 0)?.puzzle.id, "tutorial-01-close-the-gap")
        XCTAssertNil(TutorialPuzzles.level(at: 5))
    }

    func testEveryTutorialLevelIsValidAndNonTrivial() {
        for level in TutorialPuzzles.levels {
            XCTAssertEqual(validator.validate(level.puzzle), .valid, level.puzzle.id)
            XCTAssertFalse(BeamSolver.solve(level.puzzle.initialBoard).reachedGoal, level.puzzle.id)
            XCTAssertEqual(level.puzzle.parFolds, level.puzzle.solution?.count, level.puzzle.id)
        }
    }

    func testTutorialSolutionsAreStrictlyLegalAndSolve() {
        for level in TutorialPuzzles.levels {
            var board = level.puzzle.initialBoard
            for fold in level.puzzle.solution ?? [] {
                guard let outcome = FoldEngine.apply(fold, to: board) else {
                    XCTFail("\(level.puzzle.id) contains an illegal fold \(fold)")
                    return
                }
                board = outcome.board
            }
            XCTAssertTrue(BeamSolver.solve(board).reachedGoal, level.puzzle.id)
        }
    }

    func testHintSolverCanFindTutorialProgress() {
        for level in TutorialPuzzles.levels {
            let solution = FoldSolver.solution(for: level.puzzle.initialBoard, maxDepth: 8)
            XCTAssertNotNil(solution, level.puzzle.id)
            XCTAssertLessThanOrEqual(solution?.count ?? Int.max, level.puzzle.parFolds ?? Int.max, level.puzzle.id)
        }
    }

    func testNextIndexStopsAfterFinalLevel() {
        XCTAssertEqual(TutorialPuzzles.nextIndex(after: 0), 1)
        XCTAssertNil(TutorialPuzzles.nextIndex(after: TutorialPuzzles.count - 1))
    }
}
