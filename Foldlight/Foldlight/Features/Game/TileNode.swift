//
//  TileNode.swift
//  Foldlight
//
//  A single rendered board tile. The artwork comes from TileRenderer (bespoke,
//  cached vector textures per tile type); this node adds the three interactive
//  visual states (idle / lit-by-beam / emphasized) as a glowing border overlay.
//  Pure rendering — it holds no game rules.
//

import SpriteKit

final class TileNode: SKNode {
    /// Visual state of a tile.
    enum DisplayState {
        case idle
        case lit          // on the active light beam
        case emphasized   // e.g. just transformed by a combination
    }

    private let sprite: SKSpriteNode
    private let border: SKShapeNode

    init(tile: Tile, size: CGFloat, theme: BoardTheme = .default) {
        let texture = TileRenderer.texture(for: tile, size: size, theme: theme)
        sprite = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
        border = SKShapeNode(rectOf: CGSize(width: size * 0.92, height: size * 0.92), cornerRadius: size * 0.18)
        super.init()

        addChild(sprite)

        border.fillColor = .clear
        border.strokeColor = .clear
        border.lineWidth = 0
        addChild(border)

        setState(.idle)
    }

    required init?(coder aDecoder: NSCoder) {
        // Tiles are created programmatically, never decoded.
        return nil
    }

    func setState(_ state: DisplayState) {
        switch state {
        case .idle:
            border.strokeColor = .clear
            border.lineWidth = 0
            border.glowWidth = 0
        case .lit:
            border.strokeColor = GameTheme.beam
            border.lineWidth = 3
            border.glowWidth = 5
        case .emphasized:
            border.strokeColor = GameTheme.destinationOutline
            border.lineWidth = 3
            border.glowWidth = 0
        }
    }

    /// A short pulse used to draw attention to a transformed tile.
    func pulse() {
        run(.sequence([
            .scale(to: 1.15, duration: 0.12),
            .scale(to: 1.0, duration: 0.12)
        ]))
    }
}
