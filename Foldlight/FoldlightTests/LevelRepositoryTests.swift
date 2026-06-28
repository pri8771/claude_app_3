//
//  LevelRepositoryTests.swift
//  FoldlightTests
//
//  The Infinite-mode level queue produces valid puzzles on demand.
//

import XCTest
@testable import Foldlight

final class LevelRepositoryTests: XCTestCase {
    private let validator = PuzzleValidator()

    func testNextReturnsValidPuzzle() async {
        let repository = LevelRepository(generator: PuzzleGenerator(), baseSeed: 100)
        let puzzle = await repository.next(difficulty: .easy)
        XCTAssertEqual(validator.validate(puzzle), .valid)
        let folds = puzzle.parFolds ?? 0
        XCTAssertTrue(Difficulty.easy.foldRange.contains(folds))
    }

    func testRepeatedNextProducesValidPuzzles() async {
        let repository = LevelRepository(generator: PuzzleGenerator(), baseSeed: 200)
        for _ in 0..<5 {
            let puzzle = await repository.next(difficulty: .hard)
            XCTAssertEqual(validator.validate(puzzle), .valid)
        }
    }

    func testPrefetchDoesNotThrowAndNextStillValid() async {
        let repository = LevelRepository(generator: PuzzleGenerator(), baseSeed: 300)
        await repository.prefetch(difficulty: .medium)
        let puzzle = await repository.next(difficulty: .medium)
        XCTAssertEqual(validator.validate(puzzle), .valid)
    }
}
