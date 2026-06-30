//
//  HomeView.swift
//  Foldlight
//
//  The main menu / hub. Shows the player's progress summary and navigation
//  cards into every major game area. Root of the navigation stack.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ScreenScaffold {
            ScrollView {
                VStack(alignment: .leading, spacing: FoldlightSpacing.lg) {
                    header
                    progressSummary
                    menu
                }
                .padding(FoldlightSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    environment.haptics.play(.selection)
                    router.push(.settings)
                } label: {
                    Image(systemName: AppRoute.settings.systemImage)
                }
                .accessibilityLabel("Settings")
            }
        }
        .task {
            viewModel.configure(environment: environment)
            viewModel.onAppear()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: FoldlightSpacing.xs) {
            Text("Foldlight")
                .font(FoldlightTypography.largeTitle())
                .foregroundStyle(FoldlightColor.textPrimary)
            Text("Fold the board. Bend the rules. Rebuild a broken world.")
                .font(FoldlightTypography.caption())
                .foregroundStyle(FoldlightColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressSummary: some View {
        HStack(spacing: FoldlightSpacing.md) {
            StatBadge(
                icon: "sparkle",
                tint: FoldlightColor.fragment,
                value: "\(environment.profile.lightFragments)",
                label: "Fragments"
            )
            StatBadge(
                icon: "flame.fill",
                tint: FoldlightColor.warning,
                value: "\(environment.profile.dailyPuzzleStreak)",
                label: "Day Streak"
            )
            StatBadge(
                icon: environment.profile.currentBiome.systemImage,
                tint: FoldlightColor.accent,
                value: "",
                label: environment.profile.currentBiome.displayName
            )
        }
    }

    private var menu: some View {
        VStack(spacing: FoldlightSpacing.md) {
            ForEach(viewModel.menuRoutes) { route in
                MenuCard(
                    title: route.title,
                    subtitle: route.subtitle,
                    systemImage: route.systemImage,
                    tint: FoldlightColor.primary
                ) {
                    environment.haptics.play(.selection)
                    if route == .play {
                        // The Home "Play" card starts the guided vertical slice.
                        environment.pendingGameRequest = .tutorial(0)
                    }
                    router.push(route)
                }
            }
        }
    }
}

/// Small progress stat chip used in the Home summary row.
private struct StatBadge: View {
    let icon: String
    let tint: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: FoldlightSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(tint)
            if !value.isEmpty {
                Text(value)
                    .font(FoldlightTypography.numeric())
                    .foregroundStyle(FoldlightColor.textPrimary)
            }
            Text(label)
                .font(FoldlightTypography.caption())
                .foregroundStyle(FoldlightColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, FoldlightSpacing.md)
        .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: FoldlightRadius.md)
                .stroke(FoldlightColor.border, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(AppEnvironment.live())
    .environmentObject(AppRouter())
}
