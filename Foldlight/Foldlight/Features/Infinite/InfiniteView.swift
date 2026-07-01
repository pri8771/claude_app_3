//
//  InfiniteView.swift
//  Foldlight
//
//  Infinite Mode entry point. Starts the endlessly generated progression path,
//  mixing Normal, Hard, Super Hard, and Challenge levels over time.
//

import SwiftUI

struct InfiniteView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = InfiniteViewModel()

    var body: some View {
        ScreenScaffold {
            ScrollView {
                VStack(alignment: .leading, spacing: FoldlightSpacing.lg) {
                    Text("Infinite Levels")
                        .font(FoldlightTypography.title())
                        .foregroundStyle(FoldlightColor.textPrimary)

                    NextLevelCard(
                        title: viewModel.nextLevelText,
                        subtitle: viewModel.categoryText,
                        reward: viewModel.rewardText,
                        category: viewModel.nextPlan.category
                    )

                    VStack(alignment: .leading, spacing: FoldlightSpacing.sm) {
                        Text("Level Mix")
                            .font(FoldlightTypography.headline())
                            .foregroundStyle(FoldlightColor.textPrimary)
                        ForEach(viewModel.categories) { category in
                            CategoryRow(
                                category: category,
                                oddsText: viewModel.oddsText(for: category)
                            )
                        }
                    }

                    PrimaryButton("Start Level", systemImage: "play.fill") {
                        environment.haptics.play(.selection)
                        environment.pendingGameRequest = .infinite
                        router.push(.play)
                    }

                    InfoBanner(
                        systemImage: "infinity",
                        message: "The endless path gets tougher as your total completed levels climbs."
                    )
                }
                .padding(FoldlightSpacing.lg)
            }
        }
        .navigationTitle(AppRoute.infinite.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.configure(environment: environment)
            viewModel.onAppear()
        }
        .onChange(of: environment.profile) { _, profile in
            viewModel.refresh(profile: profile)
        }
    }
}

private struct NextLevelCard: View {
    let title: String
    let subtitle: String
    let reward: String
    let category: InfiniteLevelCategory

    var body: some View {
        HStack(spacing: FoldlightSpacing.md) {
            Image(systemName: category.systemImage)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(tint.opacity(0.14), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: FoldlightSpacing.xs) {
                Text(title)
                    .font(FoldlightTypography.title())
                    .foregroundStyle(FoldlightColor.textPrimary)
                Text(subtitle)
                    .font(FoldlightTypography.caption())
                    .foregroundStyle(FoldlightColor.textSecondary)
            }

            Spacer(minLength: FoldlightSpacing.sm)

            Text(reward)
                .font(FoldlightTypography.caption())
                .foregroundStyle(FoldlightColor.fragment)
                .multilineTextAlignment(.trailing)
        }
        .padding(FoldlightSpacing.md)
        .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: FoldlightRadius.md)
                .stroke(tint.opacity(0.65), lineWidth: 1)
        )
    }

    private var tint: Color {
        switch category {
        case .normal: return FoldlightColor.primary
        case .hard: return FoldlightColor.warning
        case .superHard: return FoldlightColor.fragment
        case .challenge: return FoldlightColor.accent
        }
    }
}

private struct CategoryRow: View {
    let category: InfiniteLevelCategory
    let oddsText: String

    var body: some View {
        HStack(spacing: FoldlightSpacing.md) {
            Image(systemName: category.systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)

            Text(category.displayName)
                .font(FoldlightTypography.headline())
                .foregroundStyle(FoldlightColor.textPrimary)

            Spacer()

            Text(oddsText)
                .font(FoldlightTypography.numeric())
                .foregroundStyle(FoldlightColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(FoldlightSpacing.md)
        .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: FoldlightRadius.md)
                .stroke(FoldlightColor.border, lineWidth: 1)
        )
    }

    private var tint: Color {
        switch category {
        case .normal: return FoldlightColor.primary
        case .hard: return FoldlightColor.warning
        case .superHard: return FoldlightColor.fragment
        case .challenge: return FoldlightColor.accent
        }
    }
}

#Preview {
    NavigationStack {
        InfiniteView()
    }
    .environmentObject(AppEnvironment.live())
    .environmentObject(AppRouter())
}
