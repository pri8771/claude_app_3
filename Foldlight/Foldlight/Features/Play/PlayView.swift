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

            if viewModel.hasWon {
                winOverlay
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.hasWon)
        .navigationTitle(viewModel.puzzleTitle)
        .navigationBarTitleDisplayMode(.inline)
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
        HStack(spacing: FoldlightSpacing.md) {
            Button {
                viewModel.undo()
            } label: {
                Label("Undo", systemImage: "arrow.uturn.backward")
                    .frame(maxWidth: .infinity)
            }
            .disabled(!viewModel.canUndo)

            Button {
                viewModel.reset()
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
        }
        .font(FoldlightTypography.headline())
        .foregroundStyle(FoldlightColor.primary)
        .padding(FoldlightSpacing.md)
        .background(FoldlightColor.surface.opacity(0.85), in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
    }

    private var winOverlay: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: FoldlightSpacing.lg) {
                Image(systemName: "sparkles")
                    .font(.system(size: 56))
                    .foregroundStyle(FoldlightColor.success)
                Text("Puzzle Solved")
                    .font(FoldlightTypography.title())
                    .foregroundStyle(FoldlightColor.textPrimary)
                Text("Completed in \(viewModel.moveCount) fold\(viewModel.moveCount == 1 ? "" : "s").")
                    .font(FoldlightTypography.body())
                    .foregroundStyle(FoldlightColor.textSecondary)

                VStack(spacing: FoldlightSpacing.sm) {
                    PrimaryButton(viewModel.advanceActionTitle, systemImage: "arrow.right.circle.fill") {
                        viewModel.advance()
                    }
                    Button("Back to Home") {
                        router.popToRoot()
                    }
                    .font(FoldlightTypography.headline())
                    .foregroundStyle(FoldlightColor.primary)
                }
            }
            .padding(FoldlightSpacing.xl)
            .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.lg))
            .padding(FoldlightSpacing.xl)
        }
        .transition(.opacity)
    }
}

#Preview {
    NavigationStack {
        PlayView()
    }
    .environmentObject(AppEnvironment.live())
    .environmentObject(AppRouter())
}
