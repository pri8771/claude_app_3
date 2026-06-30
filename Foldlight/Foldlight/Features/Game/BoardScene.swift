//
//  BoardScene.swift
//  Foldlight
//
//  SpriteKit renderer + input for the playable board. The scene renders a given
//  Board, animates folds / combinations / wins, and turns drag gestures into
//  candidate folds via the pure FoldGestureInterpreter. It NEVER applies rules
//  itself: it asks its owner (the GameViewModel) to apply a fold through the
//  engine, then animates from the old board to the board it is handed back.
//  This preserves strict engine/UI separation.
//

import SpriteKit
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class BoardScene: SKScene {
    // MARK: Callbacks to the owning view model (rules live there)

    /// Ask the owner to apply a fold. Returns `true` if it was legal & applied.
    var onFoldProposed: ((Fold) -> Bool)?
    /// Invoked when a gesture produced an illegal/rejected fold.
    var onFoldRejected: (() -> Void)?

    /// Whether to draw per-tile coordinate labels (debugging aid).
    var showsCoordinateLabels = false

    // MARK: Rendered state

    private var board = Board(width: 0, height: 0)
    private var beam = BeamResult(segments: [], reachedGoal: false, termination: .noSource)
    private var currentLayout = Layout(tileSize: 1, originX: 0, originY: 0, rows: 0, columns: 0)
    private var tileNodes: [BoardCoordinate: TileNode] = [:]
    private var isAnimating = false

    /// When true (user setting), fold/win animations are replaced with instant
    /// crossfades. The system Reduce Motion setting is also honored at runtime.
    var reduceMotion = false

    /// The biome skin applied to the board (tiles + background tint).
    var theme: BoardTheme = .default {
        didSet {
            guard theme != oldValue else { return }
            backgroundColor = theme.backgroundEdge
            GameTheme.current = theme
            renderCurrent()
        }
    }
    private var prefersReducedMotion: Bool {
        #if canImport(UIKit)
        return reduceMotion || UIAccessibility.isReduceMotionEnabled
        #else
        return reduceMotion
        #endif
    }

    // MARK: Layers

    private let boardLayer = SKNode()
    private let beamLayer = SKNode()
    private let previewLayer = SKNode()
    private let effectsLayer = SKNode()

    // MARK: Gesture

    private var dragStart: CGPoint?

    // MARK: - Layout

    /// Pure geometry for a board of a given size.
    private struct Layout {
        let tileSize: CGFloat
        let originX: CGFloat
        let originY: CGFloat
        let rows: Int
        let columns: Int

        func point(_ coordinate: BoardCoordinate) -> CGPoint {
            let boardHeight = tileSize * CGFloat(rows)
            return CGPoint(
                x: originX + (CGFloat(coordinate.column) + 0.5) * tileSize,
                y: originY + boardHeight - (CGFloat(coordinate.row) + 0.5) * tileSize
            )
        }
    }

    private func layout(for board: Board) -> Layout {
        let columns = max(board.width, 1)
        let rows = max(board.height, 1)
        let tile = min(size.width * 0.9 / CGFloat(columns), size.height * 0.9 / CGFloat(rows))
        let boardWidth = tile * CGFloat(columns)
        let boardHeight = tile * CGFloat(rows)
        return Layout(
            tileSize: tile,
            originX: (size.width - boardWidth) / 2,
            originY: (size.height - boardHeight) / 2,
            rows: rows,
            columns: columns
        )
    }

    // MARK: - Lifecycle

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = GameTheme.background
        boardLayer.zPosition = 0
        beamLayer.zPosition = 10
        previewLayer.zPosition = 20
        effectsLayer.zPosition = 30
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func didMove(to view: SKView) {
        isUserInteractionEnabled = true
        for layer in [boardLayer, beamLayer, previewLayer, effectsLayer] where layer.parent == nil {
            addChild(layer)
        }
        renderCurrent()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        // Never re-render mid-fold: it would wipe the tile nodes the in-flight
        // animation references and desync the board.
        guard !isAnimating else { return }
        renderCurrent()
    }

    // MARK: - Public API (called by GameViewModel)

    /// Replace the rendered board and beam instantly (no animation).
    func update(board: Board, beam: BeamResult) {
        render(board: board, beam: beam)
    }

    /// Animate a fold from `oldBoard` to `newBoard` (≈0.3s, ease-in-out), flash
    /// any combinations, then call `completion`.
    func animateFold(
        _ fold: Fold,
        from oldBoard: Board,
        to newBoard: Board,
        beam newBeam: BeamResult,
        combinations: [CombinationEvent],
        completion: @escaping () -> Void
    ) {
        guard size.width > 0, currentLayout.tileSize > 0 else {
            render(board: newBoard, beam: newBeam)
            completion()
            return
        }

        // Reduce Motion: crossfade to the new board instead of the paper-fold.
        if prefersReducedMotion {
            render(board: newBoard, beam: newBeam, landingScaleIn: false)
            for event in combinations { flashCombination(at: event.coordinate) }
            completion()
            return
        }

        // Ensure the old board is what's currently shown.
        render(board: oldBoard, beam: beam)
        isAnimating = true
        previewLayer.removeAllChildren()

        let half = 0.15
        let oldLayout = currentLayout
        let isHorizontal = fold.direction.axis == .horizontal

        // Phase 1: fold the source flap toward its destination and collapse it.
        for coordinate in oldBoard.coordinates where FoldEngine.isSource(coordinate, fold: fold) {
            guard !oldBoard.cell(at: coordinate).isEmpty, let node = tileNodes[coordinate] else { continue }
            let destination = FoldEngine.reflectedCoordinate(coordinate, fold: fold)
            let move = SKAction.move(to: oldLayout.point(destination), duration: half)
            let collapse = isHorizontal
                ? SKAction.scaleY(to: 0.1, duration: half)
                : SKAction.scaleX(to: 0.1, duration: half)
            let fade = SKAction.fadeAlpha(to: 0.5, duration: half)
            let group = SKAction.group([move, collapse, fade])
            group.timingMode = .easeIn
            node.run(group)
        }

        // Phase 2: swap to the new board (tiles scale in) and flash combinations.
        run(.sequence([
            .wait(forDuration: half),
            .run { [weak self] in
                guard let self else { return }
                self.render(board: newBoard, beam: newBeam, landingScaleIn: true)
                for event in combinations {
                    self.flashCombination(at: event.coordinate)
                }
            },
            .wait(forDuration: half),
            .run { [weak self] in
                self?.isAnimating = false
                completion()
            }
        ]))
    }

    /// Animate undoing back to a previous board (light reversal cue).
    func animateUndo(to board: Board, beam: BeamResult) {
        render(board: board, beam: beam, landingScaleIn: true)
    }

    /// Highlight a recommended fold (the hint system): a pulsing outline on the
    /// region that should fold, plus an outline of where it lands. Self-removes.
    func showHint(_ fold: Fold) {
        guard currentLayout.tileSize > 0 else { return }
        let tile = currentLayout.tileSize
        let panelSize = CGSize(width: tile * 0.92, height: tile * 0.92)

        for coordinate in board.coordinates where FoldEngine.isSource(coordinate, fold: fold) {
            guard !board.cell(at: coordinate).isEmpty else { continue }

            let highlight = SKShapeNode(rectOf: panelSize, cornerRadius: tile * 0.18)
            highlight.position = currentLayout.point(coordinate)
            highlight.fillColor = .clear
            highlight.strokeColor = GameTheme.win
            highlight.lineWidth = 3
            highlight.glowWidth = 4
            highlight.zPosition = 25
            effectsLayer.addChild(highlight)
            let pulse = SKAction.sequence([
                .fadeAlpha(to: 0.25, duration: 0.4),
                .fadeAlpha(to: 1.0, duration: 0.4)
            ])
            highlight.run(.sequence([.repeat(pulse, count: 3), .removeFromParent()]))

            let destination = FoldEngine.reflectedCoordinate(coordinate, fold: fold)
            if board.contains(destination) {
                let outline = SKShapeNode(rectOf: panelSize, cornerRadius: tile * 0.18)
                outline.position = currentLayout.point(destination)
                outline.fillColor = .clear
                outline.strokeColor = GameTheme.destinationOutline
                outline.lineWidth = 2
                outline.zPosition = 25
                effectsLayer.addChild(outline)
                outline.run(.sequence([.wait(forDuration: 2.4), .removeFromParent()]))
            }
        }
    }

    /// Celebration when the puzzle is solved: a light explosion plus a world
    /// glow, ≈1.5s (Technical PRD § "win animation").
    func playWinAnimation() {
        guard currentLayout.tileSize > 0 else { return }

        // Reduce Motion: a single calm glow, no expanding ring or flying sparks.
        if prefersReducedMotion {
            let glow = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            glow.fillColor = GameTheme.win
            glow.strokeColor = .clear
            glow.alpha = 0
            glow.zPosition = 28
            effectsLayer.addChild(glow)
            glow.run(.sequence([.fadeAlpha(to: 0.25, duration: 0.3), .fadeOut(withDuration: 0.6), .removeFromParent()]))
            return
        }

        let tile = currentLayout.tileSize

        // World glow: a full-scene flash that fades out.
        let glow = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        glow.fillColor = GameTheme.win
        glow.strokeColor = .clear
        glow.alpha = 0
        glow.zPosition = 28
        effectsLayer.addChild(glow)
        glow.run(.sequence([
            .fadeAlpha(to: 0.30, duration: 0.3),
            .fadeOut(withDuration: 1.2),
            .removeFromParent()
        ]))

        let center: CGPoint
        if let goal = board.coordinate(ofFirst: .goalCrystal) {
            center = currentLayout.point(goal)
        } else {
            center = CGPoint(x: size.width / 2, y: size.height / 2)
        }

        // Expanding ring (light explosion).
        let ring = SKShapeNode(circleOfRadius: tile * 0.4)
        ring.position = center
        ring.strokeColor = GameTheme.win
        ring.fillColor = .clear
        ring.lineWidth = 3
        ring.glowWidth = tile * 0.1
        ring.zPosition = 31
        effectsLayer.addChild(ring)
        ring.run(.sequence([
            .group([.scale(to: 10, duration: 1.2), .fadeOut(withDuration: 1.2)]),
            .removeFromParent()
        ]))

        // Radiating sparks.
        for index in 0..<12 {
            let spark = SKShapeNode(circleOfRadius: max(2, tile * 0.06))
            spark.position = center
            spark.fillColor = GameTheme.beam
            spark.strokeColor = .clear
            spark.zPosition = 32
            effectsLayer.addChild(spark)
            let angle = (CGFloat(index) / 12) * 2 * .pi
            let distance = tile * 3
            let move = SKAction.moveBy(x: cos(angle) * distance, y: sin(angle) * distance, duration: 1.2)
            move.timingMode = .easeOut
            spark.run(.sequence([
                .group([move, .fadeOut(withDuration: 1.2)]),
                .removeFromParent()
            ]))
        }
    }

    // MARK: - Rendering

    private func renderCurrent() {
        render(board: board, beam: beam)
    }

    private func render(board: Board, beam: BeamResult, landingScaleIn: Bool = false) {
        self.board = board
        self.beam = beam
        guard size.width > 0, size.height > 0, board.width > 0, board.height > 0 else { return }

        let lay = layout(for: board)
        currentLayout = lay
        boardLayer.removeAllChildren()
        beamLayer.removeAllChildren()
        tileNodes.removeAll()

        let lit = Set(beam.visitedCoordinates)
        for coordinate in board.coordinates {
            let cell = board.cell(at: coordinate)
            let node = TileNode(tile: cell.top ?? Tile(type: .empty), size: lay.tileSize, theme: theme)
            node.position = lay.point(coordinate)
            if cell.effectiveType != .empty && lit.contains(coordinate) {
                node.setState(.lit)
            }
            if landingScaleIn {
                node.setScale(0.82)
                let pop = SKAction.scale(to: 1.0, duration: 0.12)
                pop.timingMode = .easeOut
                node.run(pop)
            }
            boardLayer.addChild(node)
            tileNodes[coordinate] = node

            if showsCoordinateLabels {
                addCoordinateLabel(coordinate, at: lay.point(coordinate), tileSize: lay.tileSize)
            }
        }
        drawBeam(beam: beam, layout: lay)
    }

    private func addCoordinateLabel(_ coordinate: BoardCoordinate, at point: CGPoint, tileSize: CGFloat) {
        let label = SKLabelNode(text: "\(coordinate.row),\(coordinate.column)")
        label.fontName = "Menlo"
        label.fontSize = max(7, tileSize * 0.16)
        label.fontColor = GameTheme.grid
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .bottom
        label.position = CGPoint(x: point.x, y: point.y - tileSize * 0.42)
        label.zPosition = 5
        boardLayer.addChild(label)
    }

    private func drawBeam(beam: BeamResult, layout: Layout) {
        let coordinates = beam.visitedCoordinates
        guard coordinates.count >= 2 else { return }
        let path = CGMutablePath()
        path.move(to: layout.point(coordinates[0]))
        for coordinate in coordinates.dropFirst() {
            path.addLine(to: layout.point(coordinate))
        }
        let line = SKShapeNode(path: path)
        line.strokeColor = beam.reachedGoal ? GameTheme.win : GameTheme.beam
        line.lineWidth = max(2, layout.tileSize * 0.12)
        line.lineCap = .round
        line.lineJoin = .round
        line.glowWidth = layout.tileSize * 0.08
        beamLayer.addChild(line)
    }

    // MARK: - Combination flash (particle burst + color flash, ≈0.2s)

    private func flashCombination(at coordinate: BoardCoordinate) {
        let tile = currentLayout.tileSize
        let center = currentLayout.point(coordinate)

        let flash = SKShapeNode(rectOf: CGSize(width: tile * 0.92, height: tile * 0.92), cornerRadius: tile * 0.18)
        flash.position = center
        flash.fillColor = GameTheme.combinationFlash
        flash.strokeColor = .clear
        flash.alpha = 0
        flash.zPosition = 26
        effectsLayer.addChild(flash)
        flash.run(.sequence([
            .fadeAlpha(to: 0.85, duration: 0.06),
            .fadeOut(withDuration: 0.14),
            .removeFromParent()
        ]))

        for index in 0..<6 {
            let spark = SKShapeNode(circleOfRadius: max(1.5, tile * 0.05))
            spark.position = center
            spark.fillColor = GameTheme.beam
            spark.strokeColor = .clear
            spark.zPosition = 27
            effectsLayer.addChild(spark)
            let angle = (CGFloat(index) / 6) * 2 * .pi
            let move = SKAction.moveBy(x: cos(angle) * tile * 0.8, y: sin(angle) * tile * 0.8, duration: 0.2)
            spark.run(.sequence([
                .group([move, .fadeOut(withDuration: 0.2)]),
                .removeFromParent()
            ]))
        }

        tileNodes[coordinate]?.pulse()
    }

    private func flashIllegal(_ fold: Fold) {
        let tile = currentLayout.tileSize
        for coordinate in board.coordinates where FoldEngine.isSource(coordinate, fold: fold) {
            let overlay = SKShapeNode(rectOf: CGSize(width: tile * 0.92, height: tile * 0.92), cornerRadius: tile * 0.18)
            overlay.position = currentLayout.point(coordinate)
            overlay.fillColor = GameTheme.illegalHighlight
            overlay.strokeColor = .clear
            overlay.alpha = 0
            overlay.zPosition = 24
            effectsLayer.addChild(overlay)
            overlay.run(.sequence([
                .fadeAlpha(to: 0.7, duration: 0.06),
                .fadeOut(withDuration: 0.2),
                .removeFromParent()
            ]))
        }
    }

    // MARK: - Gesture input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isAnimating else { return }
        dragStart = touches.first?.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let start = dragStart, let current = touches.first?.location(in: self) else { return }
        updatePreview(from: start, to: current)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            dragStart = nil
            previewLayer.removeAllChildren()
        }
        guard let start = dragStart, let end = touches.first?.location(in: self) else { return }
        guard let fold = candidateFold(from: start, to: end) else { return }
        let applied = onFoldProposed?(fold) ?? false
        if !applied {
            onFoldRejected?()
            flashIllegal(fold)
            shake()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragStart = nil
        previewLayer.removeAllChildren()
    }

    private func cell(at point: CGPoint) -> BoardCoordinate? {
        let lay = currentLayout
        guard lay.tileSize > 0 else { return nil }
        let boardHeight = lay.tileSize * CGFloat(lay.rows)
        let column = Int((point.x - lay.originX) / lay.tileSize)
        let row = Int((lay.originY + boardHeight - point.y) / lay.tileSize)
        guard row >= 0, row < board.height, column >= 0, column < board.width else { return nil }
        return BoardCoordinate(row: row, column: column)
    }

    private func candidateFold(from start: CGPoint, to end: CGPoint) -> Fold? {
        guard let startCell = cell(at: start) else { return nil }
        let gesture = FoldGesture(
            startCell: startCell,
            dx: end.x - start.x,
            dyDown: start.y - end.y // SpriteKit y is up; screen-down is decreasing y.
        )
        return FoldGestureInterpreter.fold(
            for: gesture,
            boardWidth: board.width,
            boardHeight: board.height,
            minimumMagnitude: currentLayout.tileSize * 0.4
        )
    }

    private func updatePreview(from start: CGPoint, to end: CGPoint) {
        previewLayer.removeAllChildren()
        guard !isAnimating, let fold = candidateFold(from: start, to: end) else { return }
        let legal = FoldEngine.isLegal(fold, on: board)
        let tile = currentLayout.tileSize
        let panelSize = CGSize(width: tile * 0.92, height: tile * 0.92)

        for coordinate in board.coordinates where FoldEngine.isSource(coordinate, fold: fold) {
            let source = SKShapeNode(rectOf: panelSize, cornerRadius: tile * 0.18)
            source.position = currentLayout.point(coordinate)
            source.fillColor = legal ? GameTheme.legalHighlight : GameTheme.illegalHighlight
            source.strokeColor = .clear
            previewLayer.addChild(source)

            let destination = FoldEngine.reflectedCoordinate(coordinate, fold: fold)
            if board.contains(destination) {
                let outline = SKShapeNode(rectOf: panelSize, cornerRadius: tile * 0.18)
                outline.position = currentLayout.point(destination)
                outline.fillColor = .clear
                outline.strokeColor = GameTheme.destinationOutline
                outline.lineWidth = 2
                previewLayer.addChild(outline)
            }
        }
    }

    private func shake() {
        let amount = currentLayout.tileSize * 0.12
        boardLayer.run(.sequence([
            .moveBy(x: -amount, y: 0, duration: 0.04),
            .moveBy(x: amount * 2, y: 0, duration: 0.08),
            .moveBy(x: -amount, y: 0, duration: 0.04)
        ]))
    }
}
