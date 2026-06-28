//
//  DailyPuzzle.swift
//  Foldlight
//
//  The Daily Puzzle: a deterministic Medium puzzle keyed to the calendar day, so
//  every player gets the same puzzle on a given date with no server (Technical
//  PRD §4.3). Cached in memory for the session.
//

import Foundation

actor DailyPuzzleService {
    private let generator: PuzzleGenerator
    private let calendar: Calendar
    private var cache: [UInt64: Puzzle] = [:]

    init(generator: PuzzleGenerator, calendar: Calendar = .current) {
        self.generator = generator
        self.calendar = calendar
    }

    /// The seed for a given date: `year*10000 + month*100 + day`.
    nonisolated func seed(for date: Date) -> UInt64 {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return UInt64(bitPattern: Int64(year * 10000 + month * 100 + day))
    }

    /// Today's daily puzzle (cached). Always Medium difficulty.
    func today(now: Date = Date()) async -> Puzzle {
        await puzzle(for: now)
    }

    /// The daily puzzle for a specific date (used by tests). Cached by seed.
    func puzzle(for date: Date) async -> Puzzle {
        let seed = seed(for: date)
        if let cached = cache[seed] {
            return cached
        }
        let puzzle = await generator.generate(difficulty: .medium, seed: seed)
        cache[seed] = puzzle
        return puzzle
    }
}
