//
//  ProgressionTests.swift
//  FoldlightTests
//
//  Reward-loop tests: stars, fragments, repeat protection, and daily streaks.
//

import XCTest
@testable import Foldlight

final class ProgressionTests: XCTestCase {
    func testStarsScoreAgainstPar() {
        XCTAssertEqual(Progression.stars(moveCount: 3, par: 3), 3)
        XCTAssertEqual(Progression.stars(moveCount: 5, par: 3), 2)
        XCTAssertEqual(Progression.stars(moveCount: 8, par: 3), 1)
    }

    func testFragmentsScaleByDifficultyAndStars() {
        XCTAssertEqual(Progression.fragments(for: .easy, stars: 1), 5)
        XCTAssertEqual(Progression.fragments(for: .easy, stars: 3), 10)
        XCTAssertEqual(Progression.fragments(for: .expert, stars: 2), 87)
    }

    func testDailyReplaySameDayDoesNotRewardAgain() {
        var profile = PlayerProfile.new

        let first = Progression.record(
            moveCount: 1,
            parFolds: 1,
            difficulty: .medium,
            isDaily: true,
            todayKey: "2026-06-30",
            isConsecutiveDay: false,
            puzzleID: "daily-2026-06-30",
            rewardsRepeatable: false,
            into: profile
        )
        profile = first.profile

        let replay = Progression.record(
            moveCount: 1,
            parFolds: 1,
            difficulty: .medium,
            isDaily: true,
            todayKey: "2026-06-30",
            isConsecutiveDay: false,
            puzzleID: "daily-2026-06-30",
            rewardsRepeatable: false,
            into: profile
        )

        XCTAssertTrue(first.summary.didReward)
        XCTAssertFalse(replay.summary.didReward)
        XCTAssertEqual(replay.summary.fragmentsEarned, 0)
        XCTAssertEqual(replay.profile.lightFragments, first.profile.lightFragments)
        XCTAssertEqual(replay.profile.totalLevelsCompleted, first.profile.totalLevelsCompleted)
    }

    func testCuratedPuzzleRewardsOnlyOnceWhenNotRepeatable() {
        var profile = PlayerProfile.new
        let puzzleID = "tutorial-01-close-the-gap"

        let first = Progression.record(
            moveCount: 1,
            parFolds: 1,
            difficulty: .easy,
            isDaily: false,
            todayKey: nil,
            isConsecutiveDay: false,
            puzzleID: puzzleID,
            rewardsRepeatable: false,
            into: profile
        )
        profile = first.profile

        let second = Progression.record(
            moveCount: 1,
            parFolds: 1,
            difficulty: .easy,
            isDaily: false,
            todayKey: nil,
            isConsecutiveDay: false,
            puzzleID: puzzleID,
            rewardsRepeatable: false,
            into: profile
        )

        XCTAssertTrue(first.profile.completedPuzzleIDs.contains(puzzleID))
        XCTAssertTrue(first.summary.didReward)
        XCTAssertFalse(second.summary.didReward)
        XCTAssertEqual(second.profile.lightFragments, first.profile.lightFragments)
    }

    func testGeneratedPuzzleCanRewardRepeatableSessions() {
        let profile = PlayerProfile.new
        let first = Progression.record(
            moveCount: 2,
            parFolds: 2,
            difficulty: .easy,
            isDaily: false,
            todayKey: nil,
            isConsecutiveDay: false,
            puzzleID: "gen-seed-1",
            rewardsRepeatable: true,
            into: profile
        )

        let second = Progression.record(
            moveCount: 2,
            parFolds: 2,
            difficulty: .easy,
            isDaily: false,
            todayKey: nil,
            isConsecutiveDay: false,
            puzzleID: "gen-seed-1",
            rewardsRepeatable: true,
            into: first.profile
        )

        XCTAssertTrue(second.summary.didReward)
        XCTAssertGreaterThan(second.profile.lightFragments, first.profile.lightFragments)
    }
}
