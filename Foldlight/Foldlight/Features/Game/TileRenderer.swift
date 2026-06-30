//
//  TileRenderer.swift
//  Foldlight
//
//  Draws bespoke vector art for every tile type into a cached SKTexture, so the
//  SpriteKit board reads as a finished game rather than a debug grid of letters.
//  Each tile is a rounded glass panel (per-type gradient + border) carrying a
//  distinctive emblem: a radiant emitter, a faceted goal crystal, a reflective
//  mirror bar, light conduits, and so on. Textures are cached by
//  (theme, type, orientation, size) and reused across the board.
//

import SpriteKit
#if canImport(UIKit)
import UIKit

enum TileRenderer {
    private static var cache: [String: SKTexture] = [:]
    private static let renderScale: CGFloat = 3

    static func texture(for tile: Tile, size: CGFloat, theme: BoardTheme) -> SKTexture {
        let dim = max(8, Int(size.rounded()))
        let key = "\(theme.id)|\(tile.type.rawValue)|\(tile.orientation.rawValue)|\(dim)"
        if let cached = cache[key] { return cached }

        let format = UIGraphicsImageRendererFormat()
        format.scale = renderScale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: dim, height: dim), format: format)
        let image = renderer.image { context in
            draw(tile: tile, size: CGFloat(dim), theme: theme, cg: context.cgContext)
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        cache[key] = texture
        return texture
    }

    // MARK: - Drawing

    private static func draw(tile: Tile, size s: CGFloat, theme: BoardTheme, cg: CGContext) {
        let rect = CGRect(x: 0, y: 0, width: s, height: s)
        let inset = rect.insetBy(dx: s * 0.05, dy: s * 0.05)
        let radius = s * 0.18
        let colors = palette(for: tile.type, theme: theme)

        // Empty cells are a faint recess — no emblem.
        if tile.type == .empty {
            let panel = rounded(inset, radius)
            fillGradient(cg, path: panel, from: colors.top, to: colors.bottom, in: inset)
            stroke(cg, path: panel, color: theme.grid.withAlphaComponent(0.6), width: s * 0.012)
            return
        }

        // Panel.
        let panel = rounded(inset, radius)
        fillGradient(cg, path: panel, from: colors.top, to: colors.bottom, in: inset)
        // Top sheen.
        cg.saveGState()
        cg.addPath(panel); cg.clip()
        cg.setFillColor(UIColor(white: 1, alpha: 0.06).cgColor)
        cg.fill(CGRect(x: inset.minX, y: inset.minY, width: inset.width, height: inset.height * 0.42))
        cg.restoreGState()
        stroke(cg, path: panel, color: theme.grid, width: s * 0.014)

        emblem(for: tile, size: s, rect: inset, theme: theme, color: colors.icon, cg: cg)
    }

    // MARK: - Per-type palette

    private struct Palette { let top: UIColor; let bottom: UIColor; let icon: UIColor }

    private static func palette(for type: TileType, theme: BoardTheme) -> Palette {
        let accent = theme.accent
        switch type {
        case .empty:
            return Palette(top: rgb(0.12, 0.14, 0.24), bottom: rgb(0.07, 0.08, 0.16), icon: .clear)
        case .lightSource:
            return Palette(top: rgb(0.42, 0.34, 0.12), bottom: rgb(0.26, 0.20, 0.07), icon: rgb(1.0, 0.90, 0.55))
        case .goalCrystal:
            return Palette(top: rgb(0.14, 0.30, 0.24), bottom: rgb(0.08, 0.18, 0.15), icon: rgb(0.55, 0.95, 0.74))
        case .path, .bridge, .openGate, .capturedMonster:
            return Palette(top: rgb(0.20, 0.26, 0.42), bottom: rgb(0.12, 0.16, 0.30), icon: accent)
        case .mirror:
            return Palette(top: rgb(0.30, 0.26, 0.46), bottom: rgb(0.18, 0.15, 0.32), icon: rgb(0.85, 0.88, 1.0))
        case .blocker:
            return Palette(top: rgb(0.20, 0.18, 0.24), bottom: rgb(0.11, 0.10, 0.14), icon: rgb(0.40, 0.38, 0.48))
        case .steam:
            return Palette(top: rgb(0.26, 0.28, 0.34), bottom: rgb(0.16, 0.17, 0.22), icon: rgb(0.78, 0.82, 0.90))
        case .seed:
            return Palette(top: rgb(0.16, 0.30, 0.16), bottom: rgb(0.10, 0.20, 0.10), icon: rgb(0.55, 0.85, 0.45))
        case .water:
            return Palette(top: rgb(0.14, 0.26, 0.40), bottom: rgb(0.09, 0.17, 0.28), icon: rgb(0.50, 0.78, 0.98))
        case .fire:
            return Palette(top: rgb(0.40, 0.18, 0.12), bottom: rgb(0.26, 0.10, 0.07), icon: rgb(0.98, 0.62, 0.30))
        case .ice:
            return Palette(top: rgb(0.20, 0.30, 0.40), bottom: rgb(0.12, 0.20, 0.30), icon: rgb(0.74, 0.92, 1.0))
        case .key:
            return Palette(top: rgb(0.34, 0.28, 0.12), bottom: rgb(0.22, 0.18, 0.07), icon: rgb(0.95, 0.82, 0.42))
        case .lock:
            return Palette(top: rgb(0.22, 0.22, 0.28), bottom: rgb(0.13, 0.13, 0.18), icon: rgb(0.72, 0.74, 0.82))
        case .shadow:
            return Palette(top: rgb(0.16, 0.12, 0.22), bottom: rgb(0.09, 0.07, 0.14), icon: rgb(0.55, 0.45, 0.70))
        case .monster:
            return Palette(top: rgb(0.32, 0.14, 0.30), bottom: rgb(0.20, 0.08, 0.20), icon: rgb(0.92, 0.45, 0.80))
        case .cage:
            return Palette(top: rgb(0.22, 0.20, 0.24), bottom: rgb(0.13, 0.12, 0.16), icon: rgb(0.70, 0.70, 0.78))
        }
    }

    // MARK: - Emblems

    private static func emblem(for tile: Tile, size s: CGFloat, rect: CGRect, theme: BoardTheme, color: UIColor, cg: CGContext) {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        switch tile.type {
        case .lightSource:
            drawLightSource(cg, center: c, s: s, color: color, orientation: tile.orientation)
        case .goalCrystal:
            drawCrystal(cg, center: c, s: s, color: color)
        case .path:
            drawConduit(cg, center: c, s: s, color: color)
        case .mirror:
            drawMirror(cg, center: c, s: s, color: color, forwardSlash: tile.orientation.isForwardSlashMirror)
        case .blocker:
            drawBlocker(cg, rect: rect, s: s, color: color)
        case .steam:
            drawCloud(cg, center: c, s: s, color: color)
        case .bridge:
            drawConduit(cg, center: c, s: s, color: color)
            drawLeaf(cg, center: c, s: s, color: rgb(0.55, 0.85, 0.45))
        case .openGate:
            drawGate(cg, center: c, s: s, color: color)
        case .fire:
            drawFlame(cg, center: c, s: s, color: color)
        case .ice:
            drawSpark(cg, center: c, s: s, color: color)
        case .water:
            drawWaves(cg, center: c, s: s, color: color)
        case .seed:
            drawLeaf(cg, center: c, s: s, color: color)
        case .key:
            drawKey(cg, center: c, s: s, color: color)
        case .lock, .cage, .capturedMonster:
            drawLock(cg, center: c, s: s, color: color)
        case .shadow:
            drawShadow(cg, center: c, s: s, color: color)
        case .monster:
            drawBlob(cg, center: c, s: s, color: color)
        case .empty:
            break
        }
    }

    private static func drawLightSource(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor, orientation: Orientation) {
        // Rays.
        cg.setStrokeColor(color.withAlphaComponent(0.8).cgColor)
        cg.setLineWidth(s * 0.03)
        cg.setLineCap(.round)
        let r = s * 0.30
        for i in 0..<8 {
            let a = CGFloat(i) / 8 * .pi * 2
            cg.move(to: CGPoint(x: c.x + cos(a) * r * 0.7, y: c.y + sin(a) * r * 0.7))
            cg.addLine(to: CGPoint(x: c.x + cos(a) * r, y: c.y + sin(a) * r))
        }
        cg.strokePath()
        // Glowing core.
        glow(cg, color: color, blur: s * 0.10)
        cg.setFillColor(color.cgColor)
        cg.fillEllipse(in: CGRect(x: c.x - s * 0.17, y: c.y - s * 0.17, width: s * 0.34, height: s * 0.34))
        cg.setShadow(offset: .zero, blur: 0, color: nil)
        // Directional notch showing emission side.
        let dir = directionVector(orientation)
        cg.setFillColor(UIColor(white: 1, alpha: 0.95).cgColor)
        let n = CGPoint(x: c.x + dir.dx * s * 0.20, y: c.y + dir.dy * s * 0.20)
        cg.fillEllipse(in: CGRect(x: n.x - s * 0.05, y: n.y - s * 0.05, width: s * 0.10, height: s * 0.10))
    }

    private static func drawCrystal(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor) {
        let r = s * 0.26
        glow(cg, color: color, blur: s * 0.10)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: c.x, y: c.y - r))
        path.addLine(to: CGPoint(x: c.x + r * 0.72, y: c.y))
        path.addLine(to: CGPoint(x: c.x, y: c.y + r))
        path.addLine(to: CGPoint(x: c.x - r * 0.72, y: c.y))
        path.closeSubpath()
        cg.addPath(path)
        cg.setFillColor(color.cgColor)
        cg.fillPath()
        cg.setShadow(offset: .zero, blur: 0, color: nil)
        cg.addPath(path)
        cg.setStrokeColor(UIColor(white: 1, alpha: 0.85).cgColor)
        cg.setLineWidth(s * 0.016)
        cg.strokePath()
        cg.move(to: CGPoint(x: c.x, y: c.y - r)); cg.addLine(to: CGPoint(x: c.x, y: c.y + r))
        cg.setStrokeColor(UIColor(white: 1, alpha: 0.4).cgColor)
        cg.setLineWidth(s * 0.01); cg.strokePath()
    }

    private static func drawConduit(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor) {
        // A soft plus-shaped light conduit.
        cg.setFillColor(color.withAlphaComponent(0.85).cgColor)
        let arm = s * 0.30, thick = s * 0.13
        cg.fill(CGRect(x: c.x - thick / 2, y: c.y - arm / 2, width: thick, height: arm))
        cg.fill(CGRect(x: c.x - arm / 2, y: c.y - thick / 2, width: arm, height: thick))
        cg.setFillColor(color.cgColor)
        cg.fillEllipse(in: CGRect(x: c.x - thick * 0.7, y: c.y - thick * 0.7, width: thick * 1.4, height: thick * 1.4))
    }

    private static func drawMirror(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor, forwardSlash: Bool) {
        let r = s * 0.30
        let p1: CGPoint, p2: CGPoint
        if forwardSlash { // "/"
            p1 = CGPoint(x: c.x - r, y: c.y + r); p2 = CGPoint(x: c.x + r, y: c.y - r)
        } else {          // "\"
            p1 = CGPoint(x: c.x - r, y: c.y - r); p2 = CGPoint(x: c.x + r, y: c.y + r)
        }
        cg.setStrokeColor(UIColor(white: 0, alpha: 0.4).cgColor)
        cg.setLineWidth(s * 0.16); cg.setLineCap(.round)
        cg.move(to: p1); cg.addLine(to: p2); cg.strokePath()
        cg.setStrokeColor(color.cgColor)
        cg.setLineWidth(s * 0.09)
        cg.move(to: p1); cg.addLine(to: p2); cg.strokePath()
        cg.setStrokeColor(UIColor(white: 1, alpha: 0.85).cgColor)
        cg.setLineWidth(s * 0.03)
        cg.move(to: p1); cg.addLine(to: p2); cg.strokePath()
    }

    private static func drawBlocker(_ cg: CGContext, rect: CGRect, s: CGFloat, color: UIColor) {
        let block = rect.insetBy(dx: s * 0.18, dy: s * 0.18)
        cg.setFillColor(color.cgColor)
        cg.addPath(rounded(block, s * 0.08)); cg.fillPath()
        cg.setStrokeColor(UIColor(white: 0, alpha: 0.5).cgColor)
        cg.setLineWidth(s * 0.03)
        for i in 1...3 {
            let x = block.minX + block.width * CGFloat(i) / 4
            cg.move(to: CGPoint(x: x, y: block.minY)); cg.addLine(to: CGPoint(x: x, y: block.maxY))
        }
        cg.strokePath()
    }

    private static func drawCloud(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor) {
        cg.setFillColor(color.withAlphaComponent(0.85).cgColor)
        for (dx, dy, r) in [(-0.16, 0.0, 0.16), (0.10, -0.04, 0.18), (0.0, 0.10, 0.14)] {
            cg.fillEllipse(in: CGRect(x: c.x + CGFloat(dx) * s - CGFloat(r) * s, y: c.y + CGFloat(dy) * s - CGFloat(r) * s, width: CGFloat(r) * 2 * s, height: CGFloat(r) * 2 * s))
        }
    }

    private static func drawGate(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor) {
        cg.setStrokeColor(color.cgColor)
        cg.setLineWidth(s * 0.07); cg.setLineCap(.round)
        let h = s * 0.30
        cg.move(to: CGPoint(x: c.x - s * 0.18, y: c.y + h / 2)); cg.addLine(to: CGPoint(x: c.x - s * 0.18, y: c.y - h / 2))
        cg.move(to: CGPoint(x: c.x + s * 0.18, y: c.y + h / 2)); cg.addLine(to: CGPoint(x: c.x + s * 0.18, y: c.y - h / 2))
        cg.strokePath()
        drawConduit(cg, center: c, s: s * 0.7, color: color)
    }

    private static func drawFlame(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: c.x, y: c.y - s * 0.26))
        path.addQuadCurve(to: CGPoint(x: c.x, y: c.y + s * 0.26), control: CGPoint(x: c.x + s * 0.28, y: c.y))
        path.addQuadCurve(to: CGPoint(x: c.x, y: c.y - s * 0.26), control: CGPoint(x: c.x - s * 0.28, y: c.y))
        glow(cg, color: color, blur: s * 0.08)
        cg.addPath(path); cg.setFillColor(color.cgColor); cg.fillPath()
        cg.setShadow(offset: .zero, blur: 0, color: nil)
    }

    private static func drawSpark(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor) {
        cg.setStrokeColor(color.cgColor); cg.setLineWidth(s * 0.05); cg.setLineCap(.round)
        let r = s * 0.26
        for i in 0..<3 {
            let a = CGFloat(i) / 3 * .pi
            cg.move(to: CGPoint(x: c.x - cos(a) * r, y: c.y - sin(a) * r))
            cg.addLine(to: CGPoint(x: c.x + cos(a) * r, y: c.y + sin(a) * r))
        }
        cg.strokePath()
    }

    private static func drawWaves(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor) {
        cg.setStrokeColor(color.cgColor); cg.setLineWidth(s * 0.05); cg.setLineCap(.round)
        for row in 0..<2 {
            let y = c.y - s * 0.06 + CGFloat(row) * s * 0.16
            let path = CGMutablePath()
            path.move(to: CGPoint(x: c.x - s * 0.24, y: y))
            path.addCurve(to: CGPoint(x: c.x + s * 0.24, y: y),
                          control1: CGPoint(x: c.x - s * 0.08, y: y - s * 0.12),
                          control2: CGPoint(x: c.x + s * 0.08, y: y + s * 0.12))
            cg.addPath(path)
        }
        cg.strokePath()
    }

    private static func drawLeaf(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: c.x, y: c.y + s * 0.24))
        path.addQuadCurve(to: CGPoint(x: c.x, y: c.y - s * 0.24), control: CGPoint(x: c.x + s * 0.24, y: c.y))
        path.addQuadCurve(to: CGPoint(x: c.x, y: c.y + s * 0.24), control: CGPoint(x: c.x - s * 0.24, y: c.y))
        cg.addPath(path); cg.setFillColor(color.cgColor); cg.fillPath()
    }

    private static func drawKey(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor) {
        cg.setStrokeColor(color.cgColor); cg.setLineWidth(s * 0.06); cg.setLineCap(.round)
        cg.strokeEllipse(in: CGRect(x: c.x - s * 0.22, y: c.y - s * 0.12, width: s * 0.22, height: s * 0.22))
        cg.move(to: CGPoint(x: c.x, y: c.y)); cg.addLine(to: CGPoint(x: c.x + s * 0.24, y: c.y))
        cg.move(to: CGPoint(x: c.x + s * 0.20, y: c.y)); cg.addLine(to: CGPoint(x: c.x + s * 0.20, y: c.y + s * 0.10))
        cg.strokePath()
    }

    private static func drawLock(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor) {
        cg.setStrokeColor(color.cgColor); cg.setLineWidth(s * 0.05)
        cg.strokeEllipse(in: CGRect(x: c.x - s * 0.14, y: c.y - s * 0.26, width: s * 0.28, height: s * 0.28))
        cg.setFillColor(color.cgColor)
        cg.addPath(rounded(CGRect(x: c.x - s * 0.18, y: c.y - s * 0.06, width: s * 0.36, height: s * 0.28), s * 0.05))
        cg.fillPath()
    }

    private static func drawShadow(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor) {
        cg.setFillColor(color.withAlphaComponent(0.7).cgColor)
        cg.fillEllipse(in: CGRect(x: c.x - s * 0.24, y: c.y - s * 0.24, width: s * 0.48, height: s * 0.48))
        cg.setFillColor(UIColor(white: 0, alpha: 0.5).cgColor)
        cg.fillEllipse(in: CGRect(x: c.x - s * 0.12, y: c.y - s * 0.12, width: s * 0.24, height: s * 0.24))
    }

    private static func drawBlob(_ cg: CGContext, center c: CGPoint, s: CGFloat, color: UIColor) {
        cg.setFillColor(color.cgColor)
        cg.fillEllipse(in: CGRect(x: c.x - s * 0.22, y: c.y - s * 0.20, width: s * 0.44, height: s * 0.44))
        cg.setFillColor(UIColor.white.cgColor)
        cg.fillEllipse(in: CGRect(x: c.x - s * 0.12, y: c.y - s * 0.06, width: s * 0.10, height: s * 0.10))
        cg.fillEllipse(in: CGRect(x: c.x + s * 0.02, y: c.y - s * 0.06, width: s * 0.10, height: s * 0.10))
        cg.setFillColor(UIColor.black.cgColor)
        cg.fillEllipse(in: CGRect(x: c.x - s * 0.09, y: c.y - s * 0.03, width: s * 0.05, height: s * 0.05))
        cg.fillEllipse(in: CGRect(x: c.x + s * 0.05, y: c.y - s * 0.03, width: s * 0.05, height: s * 0.05))
    }

    // MARK: - Primitives

    private static func directionVector(_ o: Orientation) -> CGVector {
        switch o {
        case .deg0: return CGVector(dx: 0, dy: -1)   // up (top of tile in UIKit coords)
        case .deg90: return CGVector(dx: 1, dy: 0)   // right
        case .deg180: return CGVector(dx: 0, dy: 1)  // down
        case .deg270: return CGVector(dx: -1, dy: 0) // left
        }
    }

    private static func rounded(_ r: CGRect, _ rad: CGFloat) -> CGPath {
        CGPath(roundedRect: r, cornerWidth: rad, cornerHeight: rad, transform: nil)
    }

    private static func fillGradient(_ cg: CGContext, path: CGPath, from top: UIColor, to bottom: UIColor, in rect: CGRect) {
        cg.saveGState(); cg.addPath(path); cg.clip()
        let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                              colors: [top.cgColor, bottom.cgColor] as CFArray, locations: [0, 1])!
        cg.drawLinearGradient(grad, start: CGPoint(x: rect.midX, y: rect.minY), end: CGPoint(x: rect.midX, y: rect.maxY), options: [])
        cg.restoreGState()
    }

    private static func stroke(_ cg: CGContext, path: CGPath, color: UIColor, width: CGFloat) {
        cg.addPath(path); cg.setStrokeColor(color.cgColor); cg.setLineWidth(width); cg.strokePath()
    }

    private static func glow(_ cg: CGContext, color: UIColor, blur: CGFloat) {
        cg.setShadow(offset: .zero, blur: blur, color: color.withAlphaComponent(0.9).cgColor)
    }

    private static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
#endif
