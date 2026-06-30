//
//  DayKeyTests.swift
//  FoldlightTests
//
//  The daily-streak calendar logic: stable day keys and consecutive-day detection
//  drive whether a streak continues or resets.
//

import XCTest
@testable import Foldlight

final class DayKeyTests: XCTestCase {
    private var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }()

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var comps = DateComponents()
        comps.year = y; comps.month = m; comps.day = d
        return calendar.date(from: comps)!
    }

    func testStringFormat() {
        XCTAssertEqual(DayKey.string(for: date(2026, 6, 30), calendar: calendar), "2026-06-30")
        XCTAssertEqual(DayKey.string(for: date(2026, 1, 5), calendar: calendar), "2026-01-05")
    }

    func testRoundTrip() {
        let key = "2026-06-30"
        let parsed = DayKey.date(from: key, calendar: calendar)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(DayKey.string(for: parsed!, calendar: calendar), key)
    }

    func testConsecutiveDay() {
        XCTAssertTrue(DayKey.isConsecutive(previous: "2026-06-29", today: date(2026, 6, 30), calendar: calendar))
        // Across a month boundary.
        XCTAssertTrue(DayKey.isConsecutive(previous: "2026-06-30", today: date(2026, 7, 1), calendar: calendar))
    }

    func testNonConsecutiveAndNil() {
        XCTAssertFalse(DayKey.isConsecutive(previous: "2026-06-28", today: date(2026, 6, 30), calendar: calendar))
        XCTAssertFalse(DayKey.isConsecutive(previous: "2026-06-30", today: date(2026, 6, 30), calendar: calendar)) // same day
        XCTAssertFalse(DayKey.isConsecutive(previous: nil, today: date(2026, 6, 30), calendar: calendar))
    }
}
