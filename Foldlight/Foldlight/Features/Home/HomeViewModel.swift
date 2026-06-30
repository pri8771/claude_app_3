//
//  HomeViewModel.swift
//  Foldlight
//
//  Presentation logic for the Home screen. The view injects the shared
//  AppEnvironment via `configure` on appear (SwiftUI environment objects are
//  not available at `init`), keeping the view free of business logic (MVVM).
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    private var environment: AppEnvironment?

    /// Routes surfaced as menu cards on Home, in display order.
    let menuRoutes: [AppRoute] = [.play, .daily, .infinite, .restoration, .shop]

    /// Inject dependencies once. Idempotent.
    func configure(environment: AppEnvironment) {
        guard self.environment == nil else { return }
        self.environment = environment
    }

    /// Record a screen-view analytics event.
    func onAppear() {
        guard let analytics = environment?.analytics else { return }
        Task { await analytics.track(.screenViewed("home")) }
    }
}
