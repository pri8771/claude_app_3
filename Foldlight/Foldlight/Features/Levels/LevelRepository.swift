//
//  LevelRepository.swift
//  Foldlight
//
//  Supplies procedurally generated puzzles to Infinite Mode and keeps a small
//  pre-generated queue per difficulty so the next puzzle is ready instantly
//  (hides generation latency).
//

import Foundation

actor LevelRepository {
    private let generator: PuzzleGenerator
    private var queues: [Difficulty: [Puzzle]] = [:]
    private var seedCounter: UInt64

    /// Number of puzzles to keep pre-generated per difficulty.
    private static let prefetchTarget = 3

    init(generator: PuzzleGenerator, baseSeed: UInt64) {
        self.generator = generator
        self.seedCounter = baseSeed
    }

    /// The next puzzle for a difficulty, served from the queue when available.
    /// Triggers a background refill so subsequent calls stay instant.
    func next(difficulty: Difficulty) async -> Puzzle {
        if var queue = queues[difficulty], !queue.isEmpty {
            let puzzle = queue.removeFirst()
            queues[difficulty] = queue
            Task { await self.prefetch(difficulty: difficulty) }
            return puzzle
        }
        let puzzle = await generateNext(difficulty: difficulty)
        Task { await self.prefetch(difficulty: difficulty) }
        return puzzle
    }

    /// Top the queue back up to the prefetch target for a difficulty.
    func prefetch(difficulty: Difficulty) async {
        var queue = queues[difficulty] ?? []
        while queue.count < Self.prefetchTarget {
            queue.append(await generateNext(difficulty: difficulty))
        }
        queues[difficulty] = queue
    }

    private func generateNext(difficulty: Difficulty) async -> Puzzle {
        seedCounter = seedCounter &+ 0x9E37_79B9_7F4A_7C15
        return await generator.generate(difficulty: difficulty, seed: seedCounter)
    }
}
