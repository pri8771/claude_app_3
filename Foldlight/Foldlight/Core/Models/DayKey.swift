//
//  DayKey.swift
//  Foldlight
//
//  Calendar-day identity used for the daily-puzzle streak. A "day key" is a
//  stable `yyyy-MM-dd` string so it can be persisted in the player profile and
//  compared without timezone drift. Kept dependency-light (no DateFormatter) and
//  pure so the streak logic is fully testable.
//

import Foundation

enum DayKey {
    /// The `yyyy-MM-dd` key for a date in the given calendar.
    static func string(for date: Date, calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    /// Reconstruct the start-of-day date for a `yyyy-MM-dd` key.
    static func date(from key: String, calendar: Calendar = .current) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        var components = DateComponents()
        components.year = parts[0]
        components.month = parts[1]
        components.day = parts[2]
        return calendar.date(from: components)
    }

    /// Whether `today` falls exactly one calendar day after the day represented
    /// by `previousKey`. Used to decide whether a daily streak continues (+1) or
    /// resets to 1.
    static func isConsecutive(previous previousKey: String?, today: Date, calendar: Calendar = .current) -> Bool {
        guard let previousKey, let previousDate = date(from: previousKey, calendar: calendar) else { return false }
        let startPrevious = calendar.startOfDay(for: previousDate)
        let startToday = calendar.startOfDay(for: today)
        return calendar.dateComponents([.day], from: startPrevious, to: startToday).day == 1
    }
}
