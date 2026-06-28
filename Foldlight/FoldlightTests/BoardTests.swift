//
//  BoardTests.swift
//  FoldlightTests
//
//  Board initialization, lookup, and serialization.
//

import XCTest
@testable import Foldlight

final class BoardTests: XCTestCase {
    func testEmptyBoardInitialization() {
        let board = Board(width: 3, height: 2)
        XCTAssertEqual(board.width, 3)
        XCTAssertEqual(board.height, 2)
        for coordinate in board.coordinates {
            XCTAssertEqual(board.effectiveType(at: coordinate), .empty)
            XCTAssertTrue(board.cell(at: coordinate).isEmpty)
        }
    }

    func testTilesBuilderPlacesTiles() {
        let board = PuzzleFixtures.firstFold.initialBoard
        XCTAssertEqual(board.height, 2)
        XCTAssertEqual(board.width, 3)
        XCTAssertEqual(board.effectiveType(at: BoardCoordinate(row: 0, column: 0)), .lightSource)
        XCTAssertEqual(board.effectiveType(at: BoardCoordinate(row: 0, column: 1)), .empty)
        XCTAssertEqual(board.effectiveType(at: BoardCoordinate(row: 0, column: 2)), .goalCrystal)
        XCTAssertEqual(board.effectiveType(at: BoardCoordinate(row: 1, column: 1)), .path)
    }

    func testContainsRespectsBounds() {
        let board = Board(width: 3, height: 2)
        XCTAssertTrue(board.contains(BoardCoordinate(row: 0, column: 0)))
        XCTAssertTrue(board.contains(BoardCoordinate(row: 1, column: 2)))
        XCTAssertFalse(board.contains(BoardCoordinate(row: -1, column: 0)))
        XCTAssertFalse(board.contains(BoardCoordinate(row: 2, column: 0)))
        XCTAssertFalse(board.contains(BoardCoordinate(row: 0, column: 3)))
    }

    func testCoordinateOfFirstFindsTile() {
        let board = PuzzleFixtures.firstFold.initialBoard
        XCTAssertEqual(board.coordinate(ofFirst: .lightSource), BoardCoordinate(row: 0, column: 0))
        XCTAssertEqual(board.coordinate(ofFirst: .goalCrystal), BoardCoordinate(row: 0, column: 2))
        XCTAssertNil(board.coordinate(ofFirst: .blocker))
    }

    func testOutOfBoundsLookupIsSafe() {
        let board = Board(width: 2, height: 2)
        XCTAssertEqual(board.effectiveType(at: BoardCoordinate(row: 9, column: 9)), .empty)
        XCTAssertNil(board.tile(at: BoardCoordinate(row: 9, column: 9)))
    }

    func testInitNormalizesRaggedRows() {
        // A single short row should be padded out to the declared width.
        let board = Board(width: 3, height: 1, cells: [[Cell(Tile.path)]])
        XCTAssertEqual(board.effectiveType(at: BoardCoordinate(row: 0, column: 0)), .path)
        XCTAssertEqual(board.effectiveType(at: BoardCoordinate(row: 0, column: 1)), .empty)
        XCTAssertEqual(board.effectiveType(at: BoardCoordinate(row: 0, column: 2)), .empty)
    }

    func testPlaceAppendsLayer() {
        var board = Board(width: 1, height: 1)
        board.place(Tile(type: .blocker), at: BoardCoordinate(row: 0, column: 0))
        board.place(Tile(type: .seed), at: BoardCoordinate(row: 0, column: 0))
        XCTAssertEqual(board.cell(at: BoardCoordinate(row: 0, column: 0)).layers.count, 2)
        XCTAssertEqual(board.effectiveType(at: BoardCoordinate(row: 0, column: 0)), .seed)
    }

    func testCodableRoundTrip() throws {
        let board = PuzzleFixtures.firstFold.initialBoard
        let data = try JSONEncoder().encode(board)
        let decoded = try JSONDecoder().decode(Board.self, from: data)
        XCTAssertEqual(decoded, board)
    }
}
