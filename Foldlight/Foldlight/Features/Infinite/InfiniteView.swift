//
//  InfiniteView.swift
//  Foldlight
//
//  Infinite Mode entry point. Player picks a difficulty tier and starts an
//  endlessly-generated puzzle (generation wired up in a later phase).
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
                    Text("Choose a difficulty")
                        .font(FoldlightTypography.title())
                        .foregroundStyle(FoldlightColor.textPrimary)

                    VStack(spacing: FoldlightSpacing.sm) {
                        ForEach(viewModel.difficulties) { difficulty in
                            DifficultyRow(
                                difficulty: difficulty,
                                isSelected: difficulty == viewModel.selectedDifficulty
                            ) {
                                viewModel.select(difficulty)
                            }
                        }
                    }

                    Text("Reward: \(viewModel.rewardText)")
                        .font(FoldlightTypography.caption())
                        .foregroundStyle(FoldlightColor.fragment)

                    PrimaryButton("Generate Puzzle", systemImage: "infinity") {
                        environment.haptics.play(.selection)
                        environment.pendingGameRequest = .infinite(viewModel.selectedDifficulty)
                        router.push(.play)
                    }

                    InfoBanner(
                        systemImage: "gearshape.2",
                        message: "Puzzles are generated locally, verified by the engine, and queued ahead of play so loading stays quick."
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
    }
}

private struct DifficultyRow: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(difficulty.displayName)
                    .font(FoldlightTypography.headline())
                    .foregroundStyle(FoldlightColor.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(FoldlightColor.primary)
                }
            }
            .padding(FoldlightSpacing.md)
            .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: FoldlightRadius.md)
                    .stroke(isSelected ? FoldlightColor.primary : FoldlightColor.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    NavigationStack {
        InfiniteView()
    }
    .environmentObject(AppEnvironment.live())
    .environmentObject(AppRouter())
}
