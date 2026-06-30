//
//  BeamLoopGuardTests.swift
//  FoldlightTests
//
//  The beam's directed-edge loop guard: a closed mirror cycle must terminate as
//  `.loopGuard` without re-traversing any directed edge (no duplicate segments).
//

import XCTest
@testable import Foldlight

final class BeamLoopGuardTests: XCTestCase {
    /// A 3×3 ring of corner mirrors with the source on the left edge facing up,
    /// so the beam circulates the ring forever and never reaches a goal.
    private func mirrorRingBoard() -> Board {
        Board(tiles: [
            [Tile.mirror(.deg0), Tile.path, Tile.mirror(.deg90)],   // /  .  \
            [Tile.light(facing: .up), nil, Tile.path],              // L      .
            [Tile.mirror(.deg90), Tile.path, Tile.mirror(.deg0)]    // \  .  /
        ])
    }

    func testClosedLoopTerminatesAsLoopGuard() {
        let result = BeamSolver.solve(mirrorRingBoard())
        XCTAssertEqual(result.termination, .loopGuard)
        XCTAssertFalse(result.reachedGoal)
    }

    func testLoopProducesNoDuplicateSegments() {
        let result = BeamSolver.solve(mirrorRingBoard())
        // Each directed edge is traversed at most once thanks to the visited set.
        let unique = Set(result.segments.map { "\($0.from.row),\($0.from.column)->\($0.to.row),\($0.to.column):\($0.direction.rawValue)" })
        XCTAssertEqual(unique.count, result.segments.count, "no segment should repeat")
        XCTAssertLessThan(result.segments.count, BeamSolver.maxSteps, "should stop well before the hard cap")
    }
}
