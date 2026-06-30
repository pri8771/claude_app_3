//
//  TutorialPuzzles.swift
//  Foldlight
//
//  Five hand-authored vertical-slice puzzles. They prove the core mechanic in a
//  predictable order before the player enters the generated Infinite mode.
//

import Foundation

enum TutorialPuzzles {
    struct Level: Equatable, Sendable {
        let index: Int
        let puzzle: Puzzle
        let difficulty: Difficulty
        let lesson: String
    }

    static let levels: [Level] = [
        closeTheGap,
        sideFold,
        growBridge,
        turnTheLight,
        threeFoldLift
    ]

    static var count: Int { levels.count }

    static func level(at index: Int) -> Level? {
        guard levels.indices.contains(index) else { return nil }
        return levels[index]
    }

    static func nextIndex(after index: Int) -> Int? {
        let next = index + 1
        return levels.indices.contains(next) ? next : nil
    }

    private static let closeTheGap = Level(
        index: 0,
        puzzle: Puzzle(
            id: "tutorial-01-close-the-gap",
            title: "1 · Close the Gap",
            initialBoard: Board(tiles: [
                [Tile.light(facing: .right), nil, Tile.goal],
                [nil, Tile.path, nil]
            ]),
            parFolds: 1,
            solution: [Fold(direction: .bottomOntoTop, position: 0)]
        ),
        difficulty: .easy,
        lesson: "A single fold can carry a missing path into the beam."
    )

    private static let sideFold = Level(
        index: 1,
        puzzle: Puzzle(
            id: "tutorial-02-side-fold",
            title: "2 · Side Fold",
            initialBoard: Board(tiles: [
                [Tile.light(facing: .down), nil],
                [nil, Tile.path],
                [Tile.goal, nil]
            ]),
            parFolds: 1,
            solution: [Fold(direction: .rightOntoLeft, position: 0)]
        ),
        difficulty: .easy,
        lesson: "Folds can move across columns, too."
    )

    private static let growBridge = Level(
        index: 2,
        puzzle: Puzzle(
            id: "tutorial-03-grow-bridge",
            title: "3 · Grow a Bridge",
            initialBoard: Board(tiles: [
                [Tile.light(facing: .right), Tile(type: .seed), Tile.goal],
                [nil, Tile(type: .water), nil]
            ]),
            parFolds: 1,
            solution: [Fold(direction: .bottomOntoTop, position: 0)]
        ),
        difficulty: .easy,
        lesson: "Some overlaps transform into beam-friendly tiles."
    )

    private static let turnTheLight = Level(
        index: 3,
        puzzle: Puzzle(
            id: "tutorial-04-turn-the-light",
            title: "4 · Turn the Light",
            initialBoard: Board(tiles: [
                [Tile.light(facing: .right), Tile.mirror(.deg90)],
                [nil, nil],
                [nil, Tile.goal]
            ]),
            parFolds: 1,
            solution: [Fold(direction: .bottomOntoTop, position: 1)]
        ),
        difficulty: .medium,
        lesson: "Mirrors redirect the beam after the board changes shape."
    )

    private static let threeFoldLift = Level(
        index: 4,
        puzzle: Puzzle(
            id: "tutorial-05-three-fold-lift",
            title: "5 · Three-Fold Lift",
            initialBoard: Board(tiles: [
                [Tile.light(facing: .right), nil, Tile.goal],
                [nil, nil, nil],
                [nil, nil, nil],
                [nil, Tile.path, nil]
            ]),
            parFolds: 3,
            solution: [
                Fold(direction: .bottomOntoTop, position: 2),
                Fold(direction: .bottomOntoTop, position: 1),
                Fold(direction: .bottomOntoTop, position: 0)
            ]
        ),
        difficulty: .medium,
        lesson: "Longer puzzles ask you to fold the same idea through space."
    )
}
