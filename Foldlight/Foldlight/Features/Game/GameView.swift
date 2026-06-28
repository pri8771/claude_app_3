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
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        if uiView.scene !== scene {
            uiView.presentScene(scene)
        }
    }
}
