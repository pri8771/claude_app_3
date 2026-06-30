//
//  PlayerProfile.swift
//  Foldlight
//
//  The persisted player progression record for the MVP foundation. Mirrors the
//  PlayerProgress fields described in Technical PRD §5.1, but modeled as a plain
//  Codable value type so it can be saved with the file-based SaveService
//  (SwiftData migration is deferred to a later phase per the Phase 1 prompt).
//

import Foundation

/// Durable player progression state.
///
/// A pure `Codable` value type — no UIKit/SwiftUI/SwiftData dependency — so the
/// domain stays testable and persistence-agnostic.
struct PlayerProfile: Codable, Equatable, Sendable {
    /// Schema version for forward-compatible, versioned save migrations.
    var schemaVersion: Int
    var totalLevelsCompleted: Int
    var totalStarsEarned: Int
    var lightFragments: Int
    var hintCredits: Int
    var currentBiome: BiomeID
    var unlockedBiomes: Set<BiomeID>
    var completedPuzzleIDs: Set<String>
    var ownedProductIDs: Set<String>
    var dailyPuzzleStreak: Int
    var lastDailyCompletedDay: String?
    var totalPlayTimeSeconds: TimeInterval

    /// Current schema version. Increment when fields change to drive migration.
    static let currentSchemaVersion = 2

    init(
        schemaVersion: Int = currentSchemaVersion,
        totalLevelsCompleted: Int,
        totalStarsEarned: Int,
        lightFragments: Int,
        hintCredits: Int,
        currentBiome: BiomeID,
        unlockedBiomes: Set<BiomeID>,
        completedPuzzleIDs: Set<String>,
        ownedProductIDs: Set<String>,
        dailyPuzzleStreak: Int,
        lastDailyCompletedDay: String?,
        totalPlayTimeSeconds: TimeInterval
    ) {
        self.schemaVersion = schemaVersion
        self.totalLevelsCompleted = totalLevelsCompleted
        self.totalStarsEarned = totalStarsEarned
        self.lightFragments = lightFragments
        self.hintCredits = hintCredits
        self.currentBiome = currentBiome
        self.unlockedBiomes = unlockedBiomes
        self.completedPuzzleIDs = completedPuzzleIDs
        self.ownedProductIDs = ownedProductIDs
        self.dailyPuzzleStreak = dailyPuzzleStreak
        self.lastDailyCompletedDay = lastDailyCompletedDay
        self.totalPlayTimeSeconds = totalPlayTimeSeconds
    }

    /// A fresh profile for a brand-new player.
    static var new: PlayerProfile {
        PlayerProfile(
            schemaVersion: currentSchemaVersion,
            totalLevelsCompleted: 0,
            totalStarsEarned: 0,
            lightFragments: 0,
            hintCredits: 3,
            currentBiome: .starting,
            unlockedBiomes: [.starting],
            completedPuzzleIDs: [],
            ownedProductIDs: [],
            dailyPuzzleStreak: 0,
            lastDailyCompletedDay: nil,
            totalPlayTimeSeconds: 0
        )
    }

    /// Whether a biome is available to the player.
    func isUnlocked(_ biome: BiomeID) -> Bool {
        unlockedBiomes.contains(biome)
    }
}

private extension PlayerProfile {
    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case totalLevelsCompleted
        case totalStarsEarned
        case lightFragments
        case hintCredits
        case currentBiome
        case unlockedBiomes
        case completedPuzzleIDs
        case ownedProductIDs
        case dailyPuzzleStreak
        case lastDailyCompletedDay
        case totalPlayTimeSeconds
    }
}

extension PlayerProfile {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            schemaVersion: Self.currentSchemaVersion,
            totalLevelsCompleted: try container.decodeIfPresent(Int.self, forKey: .totalLevelsCompleted) ?? 0,
            totalStarsEarned: try container.decodeIfPresent(Int.self, forKey: .totalStarsEarned) ?? 0,
            lightFragments: try container.decodeIfPresent(Int.self, forKey: .lightFragments) ?? 0,
            hintCredits: try container.decodeIfPresent(Int.self, forKey: .hintCredits) ?? 3,
            currentBiome: try container.decodeIfPresent(BiomeID.self, forKey: .currentBiome) ?? .starting,
            unlockedBiomes: try container.decodeIfPresent(Set<BiomeID>.self, forKey: .unlockedBiomes) ?? [.starting],
            completedPuzzleIDs: try container.decodeIfPresent(Set<String>.self, forKey: .completedPuzzleIDs) ?? [],
            ownedProductIDs: try container.decodeIfPresent(Set<String>.self, forKey: .ownedProductIDs) ?? [],
            dailyPuzzleStreak: try container.decodeIfPresent(Int.self, forKey: .dailyPuzzleStreak) ?? 0,
            lastDailyCompletedDay: try container.decodeIfPresent(String.self, forKey: .lastDailyCompletedDay),
            totalPlayTimeSeconds: try container.decodeIfPresent(TimeInterval.self, forKey: .totalPlayTimeSeconds) ?? 0
        )
    }
}
