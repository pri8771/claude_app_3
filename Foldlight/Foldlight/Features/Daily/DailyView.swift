//
//  DailyView.swift
//  Foldlight
//
//  Daily Puzzle entry point. Shows today's date, deterministic seed, streak and
//  completion state, and a primary action that will launch the daily puzzle
//  once the generator and board are wired up.
//

import SwiftUI

struct DailyView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = DailyViewModel()

    var body: some View {
        ScreenScaffold {
            ScrollView {
                VStack(alignment: .leading, spacing: FoldlightSpacing.lg) {
                    VStack(alignment: .leading, spacing: FoldlightSpacing.xs) {
                        Text(viewModel.formattedDate)
                            .font(FoldlightTypography.title())
                            .foregroundStyle(FoldlightColor.textPrimary)
                        Text("A fresh hand-quality puzzle, the same for everyone today.")
                            .font(FoldlightTypography.caption())
                            .foregroundStyle(FoldlightColor.textSecondary)
                    }

                    HStack(spacing: FoldlightSpacing.md) {
                        DetailRow(label: "Streak", value: "\(viewModel.streak) days")
                        DetailRow(label: "Status", value: viewModel.isCompletedToday ? "Completed" : "Not played")
                    }

                    DetailRow(label: "Seed", value: String(viewModel.seed))

                    PrimaryButton(
                        viewModel.isCompletedToday ? "Replay Today's Puzzle" : "Play Today's Puzzle",
                        systemImage: "play.fill"
                    ) {
                        environment.haptics.play(.selection)
                        environment.pendingGameRequest = .daily
                        router.push(.play)
                    }

                    InfoBanner(
                        systemImage: "calendar.badge.clock",
                        message: "Today's seed is derived deterministically from the date, so the generator (Phase 4) reproduces the same daily puzzle on every device with no server."
                    )
                }
                .padding(FoldlightSpacing.lg)
            }
        }
        .navigationTitle(AppRoute.daily.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.configure(environment: environment)
            viewModel.onAppear()
        }
    }
}

/// A labeled value chip used on detail screens.
private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: FoldlightSpacing.xxs) {
            Text(label.uppercased())
                .font(FoldlightTypography.caption())
                .foregroundStyle(FoldlightColor.textSecondary)
            Text(value)
                .font(FoldlightTypography.headline())
                .foregroundStyle(FoldlightColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(FoldlightSpacing.md)
        .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: FoldlightRadius.md)
                .stroke(FoldlightColor.border, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        DailyView()
    }
    .environmentObject(AppEnvironment.live())
    .environmentObject(AppRouter())
}
