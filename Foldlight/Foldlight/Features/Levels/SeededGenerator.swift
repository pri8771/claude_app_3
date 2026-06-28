//
//  SeededGenerator.swift
//  Foldlight
//
//  A deterministic, seedable random number generator (SplitMix64). Used so that
//  the same seed always produces the same puzzle — required for reproducible
//  daily puzzles and deterministic generation tests. No Foundation `Hasher`
//  (which is per-process salted) and no `SystemRandomNumberGenerator`.
//

import Foundation

/// Deterministic SplitMix64 RNG conforming to `RandomNumberGenerator`.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        // Avoid a zero state degenerating the sequence.
        self.state = seed == 0 ? 0x9E37_79B9_7F4A_7C15 : seed
    }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
