//
//  AppRoute.swift
//  Foldlight
//
//  Type-safe enumeration of every navigable destination in the app shell.
//  Used as the value type for SwiftUI's NavigationStack path.
//

import Foundation

/// Every screen the user can navigate to from Home.
///
/// `Hashable` so it can drive a `NavigationStack` path; `CaseIterable` so the
/// Home menu can be generated from a single source of truth.
enum AppRoute: Hashable, Identifiable, CaseIterable {
    case play
    case daily
    case infinite
    case restoration
    case shop
    case settings

    var id: Self { self }

    /// User-facing title for navigation bars and menu cards.
    var title: String {
        switch self {
        case .play: return "Play"
        case .daily: return "Daily Puzzle"
        case .infinite: return "Infinite Mode"
        case .restoration: return "World Restoration"
        case .shop: return "Shop"
        case .settings: return "Settings"
        }
    }

    /// Short supporting description shown on the Home menu.
    var subtitle: String {
        switch self {
        case .play: return "Solve curated folding puzzles"
        case .daily: return "A fresh hand-quality puzzle every day"
        case .infinite: return "Endless generated puzzles that keep escalating"
        case .restoration: return "Spend Light Fragments to rebuild the world"
        case .shop: return "Hints, skins, and optional upgrades"
        case .settings: return "Haptics, sound, and accessibility"
        }
    }

    /// SF Symbol used to represent the destination.
    var systemImage: String {
        switch self {
        case .play: return "square.grid.3x3.fill"
        case .daily: return "calendar"
        case .infinite: return "infinity"
        case .restoration: return "globe.americas.fill"
        case .shop: return "bag.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
