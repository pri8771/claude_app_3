//
//  RestorationView.swift
//  Foldlight
//
//  World Restoration / meta-progression entry point. Shows the 10 biomes and
//  their unlock state, and the player's Light Fragment balance.
//

import SwiftUI

struct RestorationView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = RestorationViewModel()

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: FoldlightSpacing.md)]

    var body: some View {
        ScreenScaffold {
            ScrollView {
                VStack(alignment: .leading, spacing: FoldlightSpacing.lg) {
                    HStack {
                        Label("\(environment.profile.lightFragments) Fragments", systemImage: "sparkle")
                            .font(FoldlightTypography.headline())
                            .foregroundStyle(FoldlightColor.fragment)
                        Spacer()
                        Text("\(viewModel.unlockedCount)/\(BiomeID.allCases.count) restored")
                            .font(FoldlightTypography.caption())
                            .foregroundStyle(FoldlightColor.textSecondary)
                    }

                    LazyVGrid(columns: columns, spacing: FoldlightSpacing.md) {
                        ForEach(viewModel.biomeStatuses) { status in
                            BiomeCell(
                                status: status,
                                canAfford: environment.profile.lightFragments >= status.cost
                            ) {
                                Task {
                                    if status.isUnlocked {
                                        await environment.selectBiome(status.biome)
                                    } else {
                                        _ = await environment.unlockBiome(status.biome, cost: status.cost)
                                    }
                                }
                            }
                        }
                    }

                    InfoBanner(
                        systemImage: "globe.americas",
                        message: "Spend Light Fragments earned from puzzles to restore each biome. The selected biome drives the current world identity while full art skins are produced."
                    )
                }
                .padding(FoldlightSpacing.lg)
            }
        }
        .navigationTitle(AppRoute.restoration.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.configure(environment: environment)
            viewModel.onAppear()
        }
    }
}

private struct BiomeCell: View {
    let status: RestorationViewModel.BiomeStatus
    let canAfford: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: FoldlightSpacing.sm) {
            Image(systemName: status.isUnlocked ? status.biome.systemImage : "lock.fill")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(status.isUnlocked ? FoldlightColor.primary : FoldlightColor.textSecondary)
            Text(status.biome.displayName)
                .font(FoldlightTypography.caption())
                .foregroundStyle(FoldlightColor.textPrimary)
                .multilineTextAlignment(.center)
            Text(status.biome.restorationLine)
                .font(FoldlightTypography.caption())
                .foregroundStyle(FoldlightColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            Button(action: action) {
                Text(buttonTitle)
                    .font(FoldlightTypography.caption())
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, FoldlightSpacing.sm)
                    .background(buttonColor, in: RoundedRectangle(cornerRadius: FoldlightRadius.sm))
            }
            .foregroundStyle(buttonForeground)
            .disabled(isDisabled)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 172)
        .padding(.horizontal, FoldlightSpacing.sm)
        .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: FoldlightRadius.md)
                .stroke(status.isCurrent ? FoldlightColor.primary : FoldlightColor.border, lineWidth: status.isCurrent ? 2 : 1)
        )
        .opacity(status.isUnlocked ? 1 : 0.55)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private var buttonTitle: String {
        if status.isCurrent { return "Current" }
        if status.isUnlocked { return "Select" }
        return canAfford ? "Unlock \(status.cost)" : "\(status.cost) Needed"
    }

    private var buttonColor: Color {
        if status.isCurrent { return FoldlightColor.primary.opacity(0.18) }
        if status.isUnlocked || canAfford { return FoldlightColor.primary }
        return FoldlightColor.border.opacity(0.35)
    }

    private var buttonForeground: Color {
        status.isUnlocked || canAfford ? FoldlightColor.background : FoldlightColor.textSecondary
    }

    private var isDisabled: Bool {
        status.isCurrent || (!status.isUnlocked && !canAfford)
    }

    private var accessibilityText: String {
        if status.isCurrent { return "\(status.biome.displayName), current biome" }
        if status.isUnlocked { return "\(status.biome.displayName), unlocked" }
        return "\(status.biome.displayName), locked, costs \(status.cost) fragments"
    }
}

#Preview {
    NavigationStack {
        RestorationView()
    }
    .environmentObject(AppEnvironment.live())
    .environmentObject(AppRouter())
}
