//
//  BiomeID.swift
//  Foldlight
//
//  The 10 biome themes that structure world progression and the restoration
//  meta-game (Technical PRD §4.4). Defined here as a stable, ordered identifier
//  so persistence and UI can reference biomes without string typos.
//

import Foundation

/// One of Foldlight's 10 visual/world biomes, in unlock order.
enum BiomeID: String, Codable, CaseIterable, Sendable, Identifiable {
    case crystalCave
    case glassForest
    case starMap
    case shadowRealm
    case moonGarden
    case fireFjord
    case ancientLibrary
    case voidArchive
    case sunkenAtoll
    case luminousDesert

    var id: String { rawValue }

    /// The first biome a new player starts in.
    static var starting: BiomeID { .crystalCave }

    /// User-facing display name.
    var displayName: String {
        switch self {
        case .crystalCave: return "Crystal Cave"
        case .glassForest: return "Glass Forest"
        case .starMap: return "Star Map"
        case .shadowRealm: return "Shadow Realm"
        case .moonGarden: return "Moon Garden"
        case .fireFjord: return "Fire Fjord"
        case .ancientLibrary: return "Ancient Library"
        case .voidArchive: return "Void Archive"
        case .sunkenAtoll: return "Sunken Atoll"
        case .luminousDesert: return "Luminous Desert"
        }
    }

    /// Light Fragment cost to restore/unlock this biome. The first biome is
    /// free; later costs are intentionally modest for the vertical slice so a
    /// few solves can unlock visible progress.
    var unlockCost: Int {
        switch self {
        case .crystalCave: return 0
        case .glassForest: return 40
        case .starMap: return 90
        case .shadowRealm: return 160
        case .moonGarden: return 250
        case .fireFjord: return 360
        case .ancientLibrary: return 500
        case .voidArchive: return 680
        case .sunkenAtoll: return 900
        case .luminousDesert: return 1_200
        }
    }

    /// Short restoration beat shown on the world screen.
    var restorationLine: String {
        switch self {
        case .crystalCave: return "The first prism wakes."
        case .glassForest: return "Glass leaves start to sing."
        case .starMap: return "A fallen constellation returns."
        case .shadowRealm: return "The dark edge softens."
        case .moonGarden: return "Moonflowers reopen."
        case .fireFjord: return "Embers become lanterns."
        case .ancientLibrary: return "Lost shelves relight."
        case .voidArchive: return "Blank pages remember."
        case .sunkenAtoll: return "Tide pools glow again."
        case .luminousDesert: return "The horizon turns gold."
        }
    }

    /// SF Symbol used as a placeholder biome glyph until art is produced.
    var systemImage: String {
        switch self {
        case .crystalCave: return "diamond.fill"
        case .glassForest: return "tree.fill"
        case .starMap: return "sparkles"
        case .shadowRealm: return "moon.fill"
        case .moonGarden: return "leaf.fill"
        case .fireFjord: return "flame.fill"
        case .ancientLibrary: return "books.vertical.fill"
        case .voidArchive: return "circle.hexagongrid.fill"
        case .sunkenAtoll: return "water.waves"
        case .luminousDesert: return "sun.max.fill"
        }
    }
}
