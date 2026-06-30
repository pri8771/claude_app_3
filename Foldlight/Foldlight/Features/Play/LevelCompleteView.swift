//
//  LevelCompleteView.swift
//  Foldlight
//
//  The reward moment shown when a puzzle is solved: star rating vs par, Light
//  Fragments earned, and (for the daily) the streak — plus next/replay/home
//  actions. This is the single retention beat in the loop, so it reads off the
//  real CompletionSummary produced by the progression system.
//

import SwiftUI

struct LevelCompleteView: View {
    let summary: CompletionSummary
    let advanceTitle: String
    let onAdvance: () -> Void
    let onHome: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: FoldlightSpacing.lg) {
                StarRow(stars: summary.stars, animate: appeared)

                Text("Puzzle Solved")
                    .font(FoldlightTypography.title())
                    .foregroundStyle(FoldlightColor.textPrimary)

                Text(parLine)
                    .font(FoldlightTypography.body())
                    .foregroundStyle(FoldlightColor.textSecondary)

                if summary.fragmentsEarned > 0 {
                    HStack(spacing: FoldlightSpacing.xs) {
                        Image(systemName: "sparkle")
                        Text("+\(summary.fragmentsEarned)")
                            .font(FoldlightTypography.numeric())
                        Text("Fragments")
                            .font(FoldlightTypography.headline())
                    }
                    .foregroundStyle(FoldlightColor.fragment)
                    .padding(.horizontal, FoldlightSpacing.md)
                    .padding(.vertical, FoldlightSpacing.sm)
                    .background(FoldlightColor.fragment.opacity(0.12), in: Capsule())
                    .scaleEffect(appeared ? 1 : 0.6)
                    .opacity(appeared ? 1 : 0)
                } else if !summary.didReward {
                    Text(summary.isDaily ? "Already completed today — replay for practice." : "Reward already claimed — replay for mastery.")
                        .font(FoldlightTypography.caption())
                        .foregroundStyle(FoldlightColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                if summary.isDaily && summary.streak > 0 {
                    Label("\(summary.streak)-day streak", systemImage: "flame.fill")
                        .font(FoldlightTypography.headline())
                        .foregroundStyle(FoldlightColor.warning)
                }

                VStack(spacing: FoldlightSpacing.sm) {
                    PrimaryButton(advanceTitle, systemImage: "arrow.right.circle.fill", action: onAdvance)
                    Button("Back to Home", action: onHome)
                        .font(FoldlightTypography.headline())
                        .foregroundStyle(FoldlightColor.primary)
                }
                .padding(.top, FoldlightSpacing.sm)
            }
            .padding(FoldlightSpacing.xl)
            .frame(maxWidth: 360)
            .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: FoldlightRadius.lg)
                    .strokeBorder(FoldlightColor.border, lineWidth: 1)
            )
            .padding(FoldlightSpacing.xl)
            .scaleEffect(appeared ? 1 : 0.9)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { appeared = true }
        }
    }

    private var parLine: String {
        let folds = "\(summary.moveCount) fold\(summary.moveCount == 1 ? "" : "s")"
        if let par = summary.parFolds {
            return "Solved in \(folds) · par \(par)"
        }
        return "Solved in \(folds)"
    }
}

/// Three stars, filled per the rating, with a staggered pop-in.
private struct StarRow: View {
    let stars: Int
    let animate: Bool

    var body: some View {
        HStack(spacing: FoldlightSpacing.sm) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.system(size: 40))
                    .foregroundStyle(index < stars ? FoldlightColor.fragment : FoldlightColor.border)
                    .scaleEffect(animate ? 1 : 0.2)
                    .opacity(animate ? 1 : 0)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.5).delay(Double(index) * 0.12),
                        value: animate
                    )
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("\(stars) of 3 stars")
    }
}
