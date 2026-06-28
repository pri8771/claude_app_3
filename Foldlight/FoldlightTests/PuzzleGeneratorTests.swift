//
//  PuzzleGeneratorTests.swift
//  FoldlightTests
//
//  Procedural generation: solvability gate, difficulty tiers, determinism, speed.
//

import XCTest
@testable import Foldlight

final class PuzzleGeneratorTests: XCTestCase {
    private let validator = PuzzleValidator()

    func testGeneratesValidSolvablePuzzleForEachDifficulty() async {
        let generator = PuzzleGenerator()
        for (index, difficulty) in Difficulty.allCases.enumerated() {
            let puzzle = await generator.generate(difficulty: difficulty, seed: UInt64(index + 1))
            XCTAssertEqual(validator.validate(puzzle), .valid, "\(difficulty) should be valid")

            let solution = puzzle.solution ?? []
            XCTAssertFalse(solution.isEmpty, "\(difficulty) must embed a solution")

            // The embedded solution actually reaches the goal.
            let solved = FoldEngine.replay(solution, on: puzzle.initialBoard)
            XCTAssertTrue(BeamSolver.solve(solved).reachedGoal)

            // Fold count lands in the difficulty's range.
            let folds = puzzle.parFolds ?? 0
            XCTAssertTrue(difficulty.foldRange.contains(folds), "\(difficulty) folds \(folds) out of range")
        }
    }

    func testNeverReturnsUnsolvableAcrossManySeeds() async {
        let generator = PuzzleGenerator()
        for seed in UInt64(1)...UInt64(25) {
            let puzzle = await generator.generate(difficulty: .hard, seed: seed)
            XCTAssertEqual(validator.validate(puzzle), .valid, "seed \(seed) produced a non-valid puzzle")
        }
    }

    func testDeterministicForSameSeed() async {
        let generator = PuzzleGenerator()
        let first = await generator.generate(difficulty: .medium, seed: 777)
        let second = await generator.generate(difficulty: .medium, seed: 777)
        XCTAssertEqual(first, second)
    }

    func testDifferentSeedsCanDiffer() async {
        let generator = PuzzleGenerator()
        var ids = Set<String>()
        for seed in UInt64(1)...UInt64(10) {
            ids.insert(await generator.generate(difficulty: .medium, seed: seed).id)
        }
        XCTAssertGreaterThan(ids.count, 1, "generation should not be constant across seeds")
    }

    func testGenerationCompletesWithin500ms() async {
        let generator = PuzzleGenerator()
        let start = ContinuousClock.now
        _ = await generator.generate(difficulty: .expert, seed: 12345)
        let elapsed = ContinuousClock.now - start
        XCTAssertLessThan(elapsed, .milliseconds(500))
    }
}
