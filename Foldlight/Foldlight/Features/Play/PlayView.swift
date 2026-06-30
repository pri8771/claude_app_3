//
//  PlayView.swift
//  Foldlight
//
//  Puzzle play screen (Phase 3). Hosts the SpriteKit board via GameView and a
//  SwiftUI HUD (move count, status, undo/reset) plus a win overlay. All gameplay
//  rules live in the engine/GameViewModel; this view only presents state and
//  forwards button intents.
//

import SwiftUI

struct PlayView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            GameView(scene: viewModel.scene)
                .ignoresSafeArea(edges: .bottom)

            VStack {
                hud
                Spacer()
                controls
            }
            .padding(FoldlightSpacing.lg)

            if viewModel.hasWon, let summary = viewModel.lastSummary {
                LevelCompleteView(
                    summary: summary,
                    advanceTitle: viewModel.advanceActionTitle,
                    onAdvance: { viewModel.advance() },
                    onHome: { router.popToRoot() }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.hasWon)
        .navigationTitle(viewModel.puzzleTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        viewModel.reset()
                    } label: {
                        Label("Restart Puzzle", systemImage: "arrow.counterclockwise")
                    }
                    Button(role: .destructive) {
                        router.popToRoot()
                    } label: {
                        Label("Quit to Home", systemImage: "house")
                    }
                } label: {
                    Image(systemName: "pause.circle")
                        .foregroundStyle(FoldlightColor.primary)
                }
                .accessibilityLabel("Pause menu")
            }
        }
        .task {
            await viewModel.start(environment: environment)
        }
    }

    private var hud: some View {
        HStack {
            Label("\(viewModel.moveCount)", systemImage: "arrow.uturn.down.square")
                .font(FoldlightTypography.numeric())
                .foregroundStyle(FoldlightColor.textPrimary)
            Spacer()
            Text(viewModel.statusText)
                .font(FoldlightTypography.caption())
                .foregroundStyle(viewModel.isSolved ? FoldlightColor.success : FoldlightColor.textSecondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(FoldlightSpacing.md)
        .background(FoldlightColor.surface.opacity(0.85), in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
    }

    private var controls: some View {
        HStack(spacing: FoldlightSpacing.sm) {
            controlButton("Undo", systemImage: "arrow.uturn.backward", enabled: viewModel.canUndo) {
                viewModel.undo()
            }
            controlButton("Hint \(environment.profile.hintCredits)", systemImage: "lightbulb.fill", enabled: viewModel.canHint && environment.profile.hintCredits > 0) {
                viewModel.requestHint()
            }
            controlButton("Reset", systemImage: "arrow.counterclockwise", enabled: viewModel.canUndo) {
                viewModel.reset()
            }
        }
        .font(FoldlightTypography.headline())
        .foregroundStyle(FoldlightColor.primary)
        .padding(FoldlightSpacing.md)
        .background(FoldlightColor.surface.opacity(0.85), in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
    }

    private func controlButton(_ title: String, systemImage: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: FoldlightSpacing.xxs) {
                Image(systemName: systemImage)
                    .font(.system(size: 18))
                Text(title)
                    .font(FoldlightTypography.caption())
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
        .accessibilityLabel(title)
    }
}

#Preview {
    NavigationStack {
        PlayView()
    }
    .environmentObject(AppEnvironment.live())
    .environmentObject(AppRouter())
}
