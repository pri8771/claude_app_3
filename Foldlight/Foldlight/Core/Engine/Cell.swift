//
//  Cell.swift
//  Foldlight
//
//  Core engine. A board cell holds a stack of tile layers (Technical PRD §3.1:
//  "layer (0=base, 1+=folded)"). This is the overlap representation: when a fold
//  drops a tile onto an occupied cell without a matching combination rule, the
//  tiles stack and the topmost layer is the one the beam interacts with.
//

import Foundation

/// A single board cell: an ordered stack of tile layers (base first, top last).
struct Cell: Equatable, Codable, Sendable {
    var layers: [Tile]

    init(layers: [Tile] = []) {
        self.layers = layers
    }

    /// An empty cell with no tiles.
    static var empty: Cell { Cell(layers: []) }

    /// Maximum retained layer depth. Only the top layer is beam-relevant, so
    /// deeper layers from repeated non-combining folds are bounded for safety.
    static let maxLayers = 8

    /// Convenience for a single-tile cell.
    init(_ tile: Tile) {
        self.layers = [tile]
    }

    var isEmpty: Bool { layers.isEmpty }

    /// The topmost (effective) tile, if any.
    var top: Tile? { layers.last }

    /// The effective tile type the beam interacts with (`.empty` when no tiles).
    var effectiveType: TileType { layers.last?.type ?? .empty }
}
