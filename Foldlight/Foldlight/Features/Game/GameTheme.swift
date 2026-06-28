//
//  GameTheme.swift
//  Foldlight
//
//  Presentation mapping for the SpriteKit board: tile fill colors and glyphs.
//  Kept separate from the engine (which stays pure) and mirrors the SwiftUI
//  design tokens using SKColor. Glyphs are font-safe ASCII/Unicode so the
//  Phase 3 board reads clearly before bespoke tile art (E010) is produced.
//

import SpriteKit

enum GameTheme {
    // Board chrome
    static let background = SKColor(red: 0.05, green: 0.06, blue: 0.12, alpha: 1)
    static let grid = SKColor(red: 0.27, green: 0.30, blue: 0.46, alpha: 1)
    static let beam = SKColor(red: 0.98, green: 0.85, blue: 0.45, alpha: 1)
    static let win = SKColor(red: 0.45, green: 0.86, blue: 0.62, alpha: 1)

    // Fold preview
    static let legalHighlight = SKColor(red: 0.45, green: 0.86, blue: 0.62, alpha: 0.40)
    static let destinationOutline = SKColor(red: 0.56, green: 0.81, blue: 0.96, alpha: 0.9)
    static let illegalHighlight = SKColor(red: 0.96, green: 0.40, blue: 0.40, alpha: 0.55)
    static let combinationFlash = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    static let glyphColor = SKColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 1)

    /// Fill color for a tile type.
    static func fill(for type: TileType) -> SKColor {
        switch type {
        case .empty:
            return SKColor(red: 0.10, green: 0.12, blue: 0.22, alpha: 1)
        case .lightSource:
            return SKColor(red: 0.40, green: 0.34, blue: 0.10, alpha: 1)
        case .goalCrystal:
            return SKColor(red: 0.14, green: 0.36, blue: 0.26, alpha: 1)
        case .path, .bridge, .openGate, .capturedMonster:
            return SKColor(red: 0.18, green: 0.26, blue: 0.42, alpha: 1)
        case .mirror:
            return SKColor(red: 0.30, green: 0.24, blue: 0.44, alpha: 1)
        case .blocker, .steam:
            return SKColor(red: 0.22, green: 0.16, blue: 0.20, alpha: 1)
        default:
            return SKColor(red: 0.16, green: 0.18, blue: 0.30, alpha: 1)
        }
    }

    /// A short glyph for a tile (mirror direction depends on orientation).
    static func glyph(for tile: Tile) -> String {
        switch tile.type {
        case .empty: return ""
        case .lightSource: return "L"
        case .goalCrystal: return "◇"
        case .path: return "·"
        case .mirror: return tile.orientation.isForwardSlashMirror ? "/" : "\\"
        case .blocker: return "▦"
        case .seed: return "s"
        case .water: return "~"
        case .fire: return "^"
        case .ice: return "*"
        case .key: return "k"
        case .lock: return "="
        case .shadow: return "o"
        case .monster: return "m"
        case .cage: return "▢"
        case .steam: return "≈"
        case .bridge: return "="
        case .openGate: return "|"
        case .capturedMonster: return "x"
        }
    }
}
