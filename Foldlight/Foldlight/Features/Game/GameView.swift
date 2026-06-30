//
//  GameView.swift
//  Foldlight
//
//  SwiftUI bridge: GameView wraps an SKView which presents the BoardScene.
//  Using a UIViewRepresentable (rather than SpriteView) gives explicit control
//  over the SKView configuration (ProMotion frame rate, sibling ordering).
//

import SwiftUI
import SpriteKit

struct GameView: UIViewRepresentable {
    let scene: BoardScene

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.isMultipleTouchEnabled = false
        // Allow 120Hz on ProMotion devices; the system caps to the display rate.
        view.preferredFramesPerSecond = 120
        #if DEBUG
        view.showsFPS = false
        view.showsNodeCount = false
        #endif
        scene.scaleMode = .resizeFill
        view.presentScene(scene)

        // VoiceOver: describe the board and how to interact. Live puzzle state is
        // announced by the accessible HUD status text in PlayView.
        view.isAccessibilityElement = true
        view.accessibilityLabel = "Puzzle board"
        view.accessibilityHint = "Drag across the board to fold one section onto another and guide the light to the crystal."
        view.accessibilityTraits = .allowsDirectInteraction

        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        if uiView.scene !== scene {
            uiView.presentScene(scene)
        }
    }
}
