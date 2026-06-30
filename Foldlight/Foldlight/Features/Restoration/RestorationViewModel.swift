//
//  RestorationViewModel.swift
//  Foldlight
//
//  Presentation logic for the World Restoration meta-progression screen. Lists
//  all 10 biomes with their locked/unlocked state derived from the player
//  profile. Spending Light Fragments to restore nodes is implemented in the
//  meta-progression phase (FOLDLIGHT-PROMPT-005); this foundation surfaces the
//  state and the entry point.
//

import Foundation

@MainActor
final class RestorationViewModel: ObservableObject {
    private var environment: AppEnvironment?

    /// A biome paired with whether the player has unlocked it.
    struct BiomeStatus: Identifiable {
        let biome: BiomeID
        let isUnlocked: Bool
        let isCurrent: Bool
        let cost: Int
        var id: String { biome.id }
    }

    /// All biomes with current unlock state, in display order.
    var biomeStatuses: [BiomeStatus] {
        let profile = environment?.profile ?? .new
        return BiomeID.allCases.map {
            BiomeStatus(
                biome: $0,
                isUnlocked: profile.isUnlocked($0),
                isCurrent: profile.currentBiome == $0,
                cost: $0.unlockCost
            )
        }
    }

    /// Light Fragment balance available to spend on restoration.
    var fragments: Int {
        environment?.profile.lightFragments ?? 0
    }

    /// Count of unlocked biomes (for the progress summary).
    var unlockedCount: Int {
        biomeStatuses.filter(\.isUnlocked).count
    }

    func configure(environment: AppEnvironment) {
        guard self.environment == nil else { return }
        self.environment = environment
    }

    func onAppear() {
        guard let analytics = environment?.analytics else { return }
        Task { await analytics.track(.screenViewed("restoration")) }
    }
}
