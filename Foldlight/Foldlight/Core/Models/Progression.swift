//
//  Progression.swift
//  Foldlight
//
//  Pure progression rules: how solving a puzzle scores stars, awards Light
//  Fragments, advances the daily streak, and updates the player profile. Kept
//  free of services so the entire reward loop is deterministic and unit-testable
//  (the composition root applies the result and persists it).
//

import Foundation

enum Progression {
    /// The outcome of recording a completion: the updated profile plus a summary
    /// for the level-complete screen.
    struct Outcome: Equatable, Sendable {
        let profile: PlayerProfile
        let summary: CompletionSummary
    }

    /// Star rating (1–3) for solving in `moveCount` folds against `par`.
    /// 3★ = at or under par, 2★ = within a small margin, 1★ = solved.
    static func stars(moveCount: Int, par: Int?) -> Int {
        guard let par, par > 0 else { return 3 }
        if moveCount <= par { return 3 }
        let margin = max(2, (par + 1) / 2)
        if moveCount <= par + margin { return 2 }
        return 1
    }

    /// Light Fragments awarded for a solve at the given difficulty and star
    /// rating: 1★ → range lower bound, 3★ → upper bound, 2★ → midpoint.
    static func fragments(for difficulty: Difficulty, stars: Int) -> Int {
        let range = difficulty.fragmentReward
        let span = range.upperBound - range.lowerBound
        let clampedStars = min(max(stars, 1), 3)
        return range.lowerBound + span * (clampedStars - 1) / 2
    }

    /// Record a completed puzzle into a profile, returning the new profile and a
    /// summary. For the daily puzzle, only the first solve of a given day rewards;
    /// later replays that day return a no-reward summary and leave the profile
    /// unchanged except (idempotently) the recorded day.
    ///
    /// - Parameters:
    ///   - todayKey: the `yyyy-MM-dd` key for "today" (daily only; pass `nil` for
    ///     infinite/curated puzzles, which always reward).
    ///   - isConsecutiveDay: whether today is exactly one day after the last
    ///     daily completion (drives streak +1 vs reset to 1).
    static func record(
        moveCount: Int,
        parFolds: Int?,
        difficulty: Difficulty,
        isDaily: Bool,
        todayKey: String?,
        isConsecutiveDay: Bool,
        puzzleID: String?,
        rewardsRepeatable: Bool,
        into profile: PlayerProfile
    ) -> Outcome {
        let earnedStars = stars(moveCount: moveCount, par: parFolds)
        let alreadyCompleted = puzzleID.map { profile.completedPuzzleIDs.contains($0) } ?? false

        // Daily replay on the same day: no reward, profile unchanged.
        if isDaily, let todayKey, profile.lastDailyCompletedDay == todayKey {
            let summary = CompletionSummary(
                fragmentsEarned: 0,
                stars: earnedStars,
                moveCount: moveCount,
                parFolds: parFolds,
                didReward: false,
                isDaily: true,
                streak: profile.dailyPuzzleStreak,
                totalLevelsCompleted: profile.totalLevelsCompleted
            )
            return Outcome(profile: profile, summary: summary)
        }

        // Curated/tutorial replay: mark the puzzle as known but do not award the
        // economy again. Infinite puzzles pass rewardsRepeatable=true.
        if alreadyCompleted && !rewardsRepeatable {
            let summary = CompletionSummary(
                fragmentsEarned: 0,
                stars: earnedStars,
                moveCount: moveCount,
                parFolds: parFolds,
                didReward: false,
                isDaily: isDaily,
                streak: profile.dailyPuzzleStreak,
                totalLevelsCompleted: profile.totalLevelsCompleted
            )
            return Outcome(profile: profile, summary: summary)
        }

        let earnedFragments = fragments(for: difficulty, stars: earnedStars)

        var updated = profile
        updated.lightFragments += earnedFragments
        updated.totalLevelsCompleted += 1
        updated.totalStarsEarned += earnedStars
        if let puzzleID {
            updated.completedPuzzleIDs.insert(puzzleID)
        }

        if isDaily, let todayKey {
            updated.dailyPuzzleStreak = isConsecutiveDay ? profile.dailyPuzzleStreak + 1 : 1
            updated.lastDailyCompletedDay = todayKey
        }

        let summary = CompletionSummary(
            fragmentsEarned: earnedFragments,
            stars: earnedStars,
            moveCount: moveCount,
            parFolds: parFolds,
            didReward: true,
            isDaily: isDaily,
            streak: updated.dailyPuzzleStreak,
            totalLevelsCompleted: updated.totalLevelsCompleted
        )
        return Outcome(profile: updated, summary: summary)
    }
}
