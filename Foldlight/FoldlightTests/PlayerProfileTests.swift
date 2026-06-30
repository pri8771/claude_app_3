//
//  PlayerProfileTests.swift
//  FoldlightTests
//
//  Tests for the player progression value type.
//

import XCTest
@testable import Foldlight

final class PlayerProfileTests: XCTestCase {
    func testNewProfileDefaults() {
        let profile = PlayerProfile.new
        XCTAssertEqual(profile.schemaVersion, PlayerProfile.currentSchemaVersion)
        XCTAssertEqual(profile.lightFragments, 0)
        XCTAssertEqual(profile.hintCredits, 3)
        XCTAssertEqual(profile.totalLevelsCompleted, 0)
        XCTAssertEqual(profile.currentBiome, .crystalCave)
        XCTAssertEqual(profile.unlockedBiomes, [.crystalCave])
        XCTAssertTrue(profile.completedPuzzleIDs.isEmpty)
        XCTAssertTrue(profile.ownedProductIDs.isEmpty)
        XCTAssertNil(profile.lastDailyCompletedDay)
    }

    func testStartingBiomeIsUnlockedOnly() {
        let profile = PlayerProfile.new
        XCTAssertTrue(profile.isUnlocked(.crystalCave))
        XCTAssertFalse(profile.isUnlocked(.glassForest))
    }

    func testCodableRoundTrip() throws {
        var profile = PlayerProfile.new
        profile.lightFragments = 120
        profile.hintCredits = 12
        profile.dailyPuzzleStreak = 5
        profile.lastDailyCompletedDay = "2026-06-28"
        profile.unlockedBiomes = [.crystalCave, .glassForest, .starMap]
        profile.completedPuzzleIDs = ["tutorial-01-close-the-gap"]
        profile.ownedProductIDs = [StoreProductID.noAds.rawValue]

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(profile)
        let decoded = try decoder.decode(PlayerProfile.self, from: data)

        XCTAssertEqual(decoded, profile)
    }

    func testDecodingVersionOneProfileSuppliesNewFields() throws {
        let json = """
        {
          "schemaVersion": 1,
          "totalLevelsCompleted": 2,
          "totalStarsEarned": 5,
          "lightFragments": 35,
          "currentBiome": "crystalCave",
          "unlockedBiomes": ["crystalCave"],
          "dailyPuzzleStreak": 1,
          "lastDailyCompletedDay": "2026-06-28",
          "totalPlayTimeSeconds": 42
        }
        """

        let data = try XCTUnwrap(json.data(using: .utf8))
        let decoded = try JSONDecoder().decode(PlayerProfile.self, from: data)

        XCTAssertEqual(decoded.schemaVersion, PlayerProfile.currentSchemaVersion)
        XCTAssertEqual(decoded.hintCredits, 3)
        XCTAssertTrue(decoded.completedPuzzleIDs.isEmpty)
        XCTAssertTrue(decoded.ownedProductIDs.isEmpty)
        XCTAssertEqual(decoded.lightFragments, 35)
    }
}
