//
//  HapticsService.swift
//  Foldlight
//
//  Thin haptic feedback service. The Technical PRD calls for satisfying haptic
//  feedback on folds and completion (§ Design Philosophy, §9). This foundation
//  uses UIKit feedback generators (lightweight, no CoreHaptics engine lifecycle
//  to manage yet); a richer CoreHaptics implementation can replace it later
//  behind the same `Haptics` protocol.
//
//  Respects the user's `hapticsEnabled` setting — all calls are no-ops when
//  haptics are disabled.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Semantic haptic events the app can request.
enum HapticEvent: Sendable {
    case selection
    case lightImpact
    case mediumImpact
    case success
    case warning
    case error
}

/// Plays semantic haptics, gated by user preference.
@MainActor
protocol Haptics: AnyObject {
    var isEnabled: Bool { get set }
    func play(_ event: HapticEvent)
}

/// Default UIKit-backed haptics implementation.
@MainActor
final class HapticsService: Haptics {
    var isEnabled: Bool

    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    func play(_ event: HapticEvent) {
        guard isEnabled else { return }
        #if canImport(UIKit)
        switch event {
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .lightImpact:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .mediumImpact:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        #endif
    }
}
