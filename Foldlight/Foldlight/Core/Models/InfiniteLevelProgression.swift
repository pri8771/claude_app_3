//
//  InfiniteLevelProgression.swift
//  Foldlight
//
//  Gardenscapes-style infinite level planning. Player-facing categories are
//  separate from the generator's mechanical difficulty so the game can mix
//  Normal, Hard, Super Hard, and Challenge moments while the underlying puzzle
//  system keeps using its verified solvable tiers.
//

import Foundation

/// The label players see before and during generated infinite levels.
enum InfiniteLevelCategory: String, Codable, CaseIterable, Sendable, Identifiable {
    case normal
    case hard
    case superHard
    case challenge

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .hard: return "Hard"
        case .superHard: return "Super Hard"
        case .challenge: return "Challenge"
        }
    }

    var systemImage: String {
        switch self {
        case .normal: return "sparkle"
        case .hard: return "diamond.fill"
        case .superHard: return "flame.fill"
        case .challenge: return "crown.fill"
        }
    }

    fileprivate var difficultyOffset: Int {
        switch self {
        case .normal: return 0
        case .hard: return 1
        case .superHard: return 2
        case .challenge: return 3
        }
    }
}

/// A fully resolved generated level request.
struct InfiniteLevelPlan: Equatable, Sendable {
    let levelNumber: Int
    let category: InfiniteLevelCategory
    let generatorDifficulty: Difficulty

    var title: String {
        "\(category.displayName) Level \(levelNumber)"
    }
}

enum InfiniteLevelProgression {
    struct CategoryWeight: Equatable, Sendable {
        let category: InfiniteLevelCategory
        let percent: Int
    }

    /// Resolve the next generated level from completed progression. The same
    /// completed count always yields the same category, which keeps retries and
    /// test runs stable while still feeling randomized across the endless path.
    static func plan(afterCompletedLevels completedLevels: Int) -> InfiniteLevelPlan {
        let levelNumber = max(1, completedLevels + 1)
        let category = category(forLevelNumber: levelNumber)
        return InfiniteLevelPlan(
            levelNumber: levelNumber,
            category: category,
            generatorDifficulty: generatorDifficulty(forLevelNumber: levelNumber, category: category)
        )
    }

    /// Current category odds for a specific upcoming level. Kept public to the
    /// app module so Infinite Mode can preview the mix without duplicating rules.
    static func categoryWeights(forLevelNumber levelNumber: Int) -> [CategoryWeight] {
        switch max(1, levelNumber) {
        case 1...5:
            return [CategoryWeight(category: .normal, percent: 100)]
        case 6...15:
            return [
                CategoryWeight(category: .normal, percent: 80),
                CategoryWeight(category: .hard, percent: 20)
            ]
        case 16...30:
            return [
                CategoryWeight(category: .normal, percent: 65),
                CategoryWeight(category: .hard, percent: 25),
                CategoryWeight(category: .superHard, percent: 10)
            ]
        case 31...60:
            return [
                CategoryWeight(category: .normal, percent: 55),
                CategoryWeight(category: .hard, percent: 30),
                CategoryWeight(category: .superHard, percent: 12),
                CategoryWeight(category: .challenge, percent: 3)
            ]
        default:
            return [
                CategoryWeight(category: .normal, percent: 50),
                CategoryWeight(category: .hard, percent: 30),
                CategoryWeight(category: .superHard, percent: 15),
                CategoryWeight(category: .challenge, percent: 5)
            ]
        }
    }

    private static func category(forLevelNumber levelNumber: Int) -> InfiniteLevelCategory {
        let roll = categoryRoll(forLevelNumber: levelNumber)
        var runningTotal = 0

        for weight in categoryWeights(forLevelNumber: levelNumber) {
            runningTotal += weight.percent
            if roll <= runningTotal {
                return weight.category
            }
        }
        return .normal
    }

    private static func categoryRoll(forLevelNumber levelNumber: Int) -> Int {
        var value = UInt64(max(1, levelNumber)) &* 0xA24B_AED4_963E_E407 &+ 0xF01D
        value = (value ^ (value >> 30)) &* 0xBF58_476D_1CE4_E5B9
        value = (value ^ (value >> 27)) &* 0x94D0_49BB_1331_11EB
        value = value ^ (value >> 31)
        return Int(value % 100) + 1
    }

    private static func generatorDifficulty(forLevelNumber levelNumber: Int, category: InfiniteLevelCategory) -> Difficulty {
        let tiers = Difficulty.allCases
        let baseIndex = tiers.firstIndex(of: baselineDifficulty(forLevelNumber: levelNumber)) ?? 0
        let resolvedIndex = min(baseIndex + category.difficultyOffset, tiers.count - 1)
        return tiers[resolvedIndex]
    }

    private static func baselineDifficulty(forLevelNumber levelNumber: Int) -> Difficulty {
        switch max(1, levelNumber) {
        case 1...8: return .easy
        case 9...24: return .medium
        case 25...49: return .hard
        default: return .expert
        }
    }
}
