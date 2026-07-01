//
//  InfiniteLevelProgressionTests.swift
//  FoldlightTests
//
//  Infinite mode category planning: generated levels should start approachable,
//  unlock harder category odds over time, and cap safely at the generator's
//  strongest verified tier.
//

import XCTest
@testable import Foldlight

final class InfiniteLevelProgressionTests: XCTestCase {
    func testFirstFiveLevelsAreNormalEasyLevels() {
        for completed in 0..<5 {
            let plan = InfiniteLevelProgression.plan(afterCompletedLevels: completed)
            XCTAssertEqual(plan.levelNumber, completed + 1)
            XCTAssertEqual(plan.category, .normal)
            XCTAssertEqual(plan.generatorDifficulty, .easy)
        }
    }

    func testCategoryWeightsUnlockHarderLevelTypesOverTime() {
        XCTAssertEqual(InfiniteLevelProgression.categoryWeights(forLevelNumber: 1), [
            .init(category: .normal, percent: 100)
        ])

        XCTAssertEqual(InfiniteLevelProgression.categoryWeights(forLevelNumber: 20), [
            .init(category: .normal, percent: 65),
            .init(category: .hard, percent: 25),
            .init(category: .superHard, percent: 10)
        ])

        XCTAssertEqual(InfiniteLevelProgression.categoryWeights(forLevelNumber: 50), [
            .init(category: .normal, percent: 55),
            .init(category: .hard, percent: 30),
            .init(category: .superHard, percent: 12),
            .init(category: .challenge, percent: 3)
        ])
    }

    func testWeightsAlwaysTotalOneHundredPercent() {
        for levelNumber in [1, 6, 16, 31, 61, 500] {
            let total = InfiniteLevelProgression.categoryWeights(forLevelNumber: levelNumber)
                .reduce(0) { $0 + $1.percent }
            XCTAssertEqual(total, 100, "level \(levelNumber)")
        }
    }

    func testPlanIsDeterministicForSameProgress() {
        let first = InfiniteLevelProgression.plan(afterCompletedLevels: 42)
        let second = InfiniteLevelProgression.plan(afterCompletedLevels: 42)
        XCTAssertEqual(first, second)
    }

    func testLateProgressionUsesExpertGeneratorTier() {
        let plan = InfiniteLevelProgression.plan(afterCompletedLevels: 70)
        XCTAssertEqual(plan.levelNumber, 71)
        XCTAssertEqual(plan.generatorDifficulty, .expert)
    }
}
