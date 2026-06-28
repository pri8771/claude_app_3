//
//  DailyPuzzleTests.swift
//  FoldlightTests
//
//  The deterministic daily puzzle: same-day stability and date sensitivity.
//

import XCTest
@testable import Foldlight

final class DailyPuzzleTests: XCTestCase {
    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        return utc.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }

    func testSeedMatchesDateFormula() async {
        let service = DailyPuzzleService(generator: PuzzleGenerator(), calendar: utc)
        let seed = service.seed(for: date(2026, 6, 28))
        XCTAssertEqual(seed, UInt64(2026 * 10000 + 6 * 100 + 28))
    }

    func testSameDayReturnsIdenticalPuzzle() async {
        let service = DailyPuzzleService(generator: PuzzleGenerator(), calendar: utc)
        let day = date(2026, 6, 28)
        let first = await service.puzzle(for: day)
        let second = await service.puzzle(for: day)
        XCTAssertEqual(first, second)
    }

    func testDifferentDatesProduceDifferentPuzzles() async {
        let service = DailyPuzzleService(generator: PuzzleGenerator(), calendar: utc)
        let a = await service.puzzle(for: date(2026, 6, 28))
        let b = await service.puzzle(for: date(2026, 6, 29))
        XCTAssertNotEqual(a.id, b.id)
    }

    func testDailyPuzzleIsMediumDifficulty() async {
        let service = DailyPuzzleService(generator: PuzzleGenerator(), calendar: utc)
        let puzzle = await service.puzzle(for: date(2026, 6, 28))
        let folds = puzzle.parFolds ?? 0
        XCTAssertTrue(Difficulty.medium.foldRange.contains(folds))
    }
}
