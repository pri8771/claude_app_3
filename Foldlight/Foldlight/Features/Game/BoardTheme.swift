//
//  BoardTheme.swift
//  Foldlight
//
//  The board's visual skin. Holds the chrome colors (background, beam, grid) plus
//  a biome accent so each of the 10 biomes can re-skin the same engine board. The
//  beam stays warm gold and the goal stays crystal-teal across biomes for
//  readability; the background and accent shift to give each world its mood.
//

import SpriteKit

struct BoardTheme: Equatable {
    let id: String
    /// Background gradient: center → edge.
    let backgroundCenter: SKColor
    let backgroundEdge: SKColor
    /// Hairline grid / tile border.
    let grid: SKColor
    /// The light beam.
    let beam: SKColor
    /// Goal-reached / success highlight.
    let win: SKColor
    /// Biome accent (source glow ring, empty-tile tint, conduits).
    let accent: SKColor

    // Derived fold-preview colors.
    var legalHighlight: SKColor { win.withAlpha(0.40) }
    var illegalHighlight: SKColor { SKColor(red: 0.96, green: 0.40, blue: 0.40, alpha: 0.55) }
    var destinationOutline: SKColor { SKColor(red: 0.56, green: 0.81, blue: 0.96, alpha: 0.9) }
    var combinationFlash: SKColor { SKColor(white: 1, alpha: 1) }
    var glyphColor: SKColor { SKColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 1) }

    static let `default` = BoardTheme.forBiome(.crystalCave)

    /// The skin for a biome.
    static func forBiome(_ biome: BiomeID) -> BoardTheme {
        let beam = SKColor(red: 0.98, green: 0.85, blue: 0.45, alpha: 1)
        let win = SKColor(red: 0.45, green: 0.86, blue: 0.62, alpha: 1)
        func make(_ bg: (CGFloat, CGFloat, CGFloat), _ edge: (CGFloat, CGFloat, CGFloat), _ accent: (CGFloat, CGFloat, CGFloat)) -> BoardTheme {
            BoardTheme(
                id: biome.rawValue,
                backgroundCenter: SKColor(red: edge.0, green: edge.1, blue: edge.2, alpha: 1),
                backgroundEdge: SKColor(red: bg.0, green: bg.1, blue: bg.2, alpha: 1),
                grid: SKColor(red: accent.0 * 0.5, green: accent.1 * 0.5, blue: accent.2 * 0.6, alpha: 1),
                beam: beam,
                win: win,
                accent: SKColor(red: accent.0, green: accent.1, blue: accent.2, alpha: 1)
            )
        }
        switch biome {
        case .crystalCave:    return make((0.04, 0.05, 0.11), (0.10, 0.12, 0.24), (0.55, 0.45, 0.85))
        case .glassForest:    return make((0.03, 0.09, 0.08), (0.07, 0.16, 0.14), (0.40, 0.80, 0.55))
        case .starMap:        return make((0.04, 0.05, 0.14), (0.09, 0.10, 0.26), (0.45, 0.62, 0.95))
        case .shadowRealm:    return make((0.07, 0.05, 0.10), (0.13, 0.09, 0.18), (0.62, 0.40, 0.80))
        case .moonGarden:     return make((0.05, 0.09, 0.11), (0.11, 0.16, 0.20), (0.55, 0.85, 0.75))
        case .fireFjord:      return make((0.10, 0.06, 0.07), (0.18, 0.10, 0.10), (0.95, 0.55, 0.35))
        case .ancientLibrary: return make((0.09, 0.07, 0.05), (0.16, 0.12, 0.08), (0.85, 0.70, 0.40))
        case .voidArchive:    return make((0.04, 0.04, 0.06), (0.09, 0.09, 0.13), (0.45, 0.80, 0.85))
        case .sunkenAtoll:    return make((0.03, 0.08, 0.11), (0.06, 0.15, 0.20), (0.40, 0.78, 0.80))
        case .luminousDesert: return make((0.10, 0.08, 0.05), (0.18, 0.14, 0.09), (0.95, 0.80, 0.45))
        }
    }
}

extension SKColor {
    func withAlpha(_ alpha: CGFloat) -> SKColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return SKColor(red: r, green: g, blue: b, alpha: alpha)
    }
}
