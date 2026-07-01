//
//  InfiniteViewModel.swift
//  Foldlight
//
//  Presentation state for Infinite Mode. Previews the next progression-planned
//  generated level and the current Gardenscapes-style category mix.
//

import Foundation

@MainActor
final class InfiniteViewModel: ObservableObject {
    private var environment: AppEnvironment?

    @Published private(set) var nextPlan = InfiniteLevelProgression.plan(afterCompletedLevels: 0)

    let categories = InfiniteLevelCategory.allCases

    var nextLevelText: String {
        nextPlan.title
    }

    var categoryText: String {
        "\(nextPlan.category.displayName) · \(nextPlan.generatorDifficulty.displayName)"
    }

    /// Reward range label for the next generated tier, e.g. "5–10 Fragments".
    var rewardText: String {
        let range = nextPlan.generatorDifficulty.fragmentReward
        return "\(range.lowerBound)–\(range.upperBound) Fragments"
    }

    func configure(environment: AppEnvironment) {
        if self.environment == nil {
            self.environment = environment
        }
        refresh(profile: environment.profile)
    }

    func refresh(profile: PlayerProfile) {
        nextPlan = InfiniteLevelProgression.plan(afterCompletedLevels: profile.totalLevelsCompleted)
    }

    func oddsText(for category: InfiniteLevelCategory) -> String {
        let weights = InfiniteLevelProgression.categoryWeights(forLevelNumber: nextPlan.levelNumber)
        let percent = weights.first { $0.category == category }?.percent ?? 0
        return "\(percent)%"
    }

    func onAppear() {
        guard let analytics = environment?.analytics else { return }
        Task { await analytics.track(.screenViewed("infinite")) }
    }
}
