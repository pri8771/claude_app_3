//
//  GameTheme.swift
//  Foldlight
//
//  Board chrome colors for the SpriteKit scene. This is a thin forwarding layer
//  over the active `BoardTheme`, so changing the biome skin (`GameTheme.current`)
//  re-tints the background, beam, grid, and fold-preview highlights everywhere
//  they are referenced. Tile artwork itself is produced by TileRenderer.
//

import SpriteKit

enum GameTheme {
    /// The active board skin. Set by BoardScene when its `theme` changes.
    static var current: BoardTheme = .default

    static var background: SKColor { current.backgroundEdge }
    static var grid: SKColor { current.grid }
    static var beam: SKColor { current.beam }
    static var win: SKColor { current.win }
    static var legalHighlight: SKColor { current.legalHighlight }
    static var illegalHighlight: SKColor { current.illegalHighlight }
    static var destinationOutline: SKColor { current.destinationOutline }
    static var combinationFlash: SKColor { current.combinationFlash }
    static var glyphColor: SKColor { current.glyphColor }
}
