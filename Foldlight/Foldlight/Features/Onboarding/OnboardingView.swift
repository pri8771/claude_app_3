//
//  OnboardingView.swift
//  Foldlight
//
//  First-run entry that points players directly into the guided puzzle path.
//  The actual mechanic is taught by the five tutorial boards, not by a long
//  explanation screen.
//

import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var page = 0

    private let pages = [
        OnboardingPage(
            title: "Foldlight",
            subtitle: "Fold the board. Bend the light. Restore the world.",
            systemImage: "square.grid.3x3.fill",
            tint: FoldlightColor.primary
        ),
        OnboardingPage(
            title: "Every Fold Matters",
            subtitle: "The first five puzzles teach the core moves through play.",
            systemImage: "arrow.uturn.down.square.fill",
            tint: FoldlightColor.fragment
        ),
        OnboardingPage(
            title: "No Cloud Required",
            subtitle: "Progress, daily puzzles, and generated levels all run locally.",
            systemImage: "lock.fill",
            tint: FoldlightColor.success
        )
    ]

    var body: some View {
        ScreenScaffold {
            VStack(spacing: FoldlightSpacing.lg) {
                Spacer(minLength: FoldlightSpacing.lg)

                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                PrimaryButton(page == pages.indices.last ? "Begin" : "Continue", systemImage: "arrow.right") {
                    if page == pages.indices.last {
                        onComplete()
                    } else {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            page += 1
                        }
                    }
                }

                Button("Skip") {
                    onComplete()
                }
                .font(FoldlightTypography.caption())
                .foregroundStyle(FoldlightColor.textSecondary)
                .padding(.bottom, FoldlightSpacing.lg)
            }
            .padding(FoldlightSpacing.lg)
        }
    }
}

private struct OnboardingPage {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: FoldlightSpacing.lg) {
            Image(systemName: page.systemImage)
                .font(.system(size: 72, weight: .semibold))
                .foregroundStyle(page.tint)
                .frame(width: 132, height: 132)
                .background(page.tint.opacity(0.14), in: RoundedRectangle(cornerRadius: FoldlightRadius.lg))

            VStack(spacing: FoldlightSpacing.sm) {
                Text(page.title)
                    .font(FoldlightTypography.largeTitle())
                    .foregroundStyle(FoldlightColor.textPrimary)
                    .multilineTextAlignment(.center)
                Text(page.subtitle)
                    .font(FoldlightTypography.body())
                    .foregroundStyle(FoldlightColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, FoldlightSpacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
