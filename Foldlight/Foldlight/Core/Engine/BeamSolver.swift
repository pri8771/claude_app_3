//
//  BeamSolver.swift
//  Foldlight
//
//  Core engine. Traces the light beam from the source by raycasting across the
//  board, reflecting off mirrors and stopping at blockers, the goal, or the
//  board edge. A hard step cap prevents infinite loops (Technical PRD §3.4).
//

import Foundation

/// Stateless light-beam ray tracer.
enum BeamSolver {
    /// Defensive hard cap on steps. The primary loop guard is the visited
    /// directed-edge set below; this only backstops a pathological board.
    static let maxSteps = 4096

    /// The traversal state that fully determines the beam's future: where it is
    /// and which way it is heading. Revisiting an identical state means the beam
    /// has entered a cycle, so the trace can terminate immediately (a true
    /// directed-edge loop guard rather than a step cap).
    private struct BeamState: Hashable {
        let position: BoardCoordinate
        let direction: BeamDirection
    }

    /// Trace the beam on a board and return the segments plus whether the goal
    /// was reached.
    static func solve(_ board: Board) -> BeamResult {
        guard let source = board.coordinate(ofFirst: .lightSource) else {
            return BeamResult(segments: [], reachedGoal: false, termination: .noSource)
        }

        let orientation = board.tile(at: source)?.orientation ?? .deg90
        var direction = BeamDirection(emitting: orientation)
        var position = source
        var segments: [BeamSegment] = []
        var visited: Set<BeamState> = []

        while segments.count < maxSteps {
            // If we have already traversed this (position, direction), the beam
            // is looping — stop before emitting a duplicate segment.
            guard visited.insert(BeamState(position: position, direction: direction)).inserted else {
                return BeamResult(segments: segments, reachedGoal: false, termination: .loopGuard)
            }

            let next = position.offset(direction)

            guard board.contains(next) else {
                return BeamResult(segments: segments, reachedGoal: false, termination: .exitedBoard)
            }

            segments.append(BeamSegment(from: position, to: next, direction: direction))

            switch board.effectiveType(at: next).beamBehavior {
            case .goal:
                return BeamResult(segments: segments, reachedGoal: true, termination: .reachedGoal)
            case .conduct, .source:
                position = next
            case .reflect:
                let mirrorOrientation = board.tile(at: next)?.orientation ?? .deg0
                direction = direction.reflected(off: mirrorOrientation)
                position = next
            case .block:
                return BeamResult(segments: segments, reachedGoal: false, termination: .blocked)
            }
        }

        return BeamResult(segments: segments, reachedGoal: false, termination: .loopGuard)
    }
}
