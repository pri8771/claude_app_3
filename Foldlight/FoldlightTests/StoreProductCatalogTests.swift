//
//  StoreProductCatalogTests.swift
//  FoldlightTests
//
//  Static checks for the StoreKit product catalog.
//

import XCTest
@testable import Foldlight

final class StoreProductCatalogTests: XCTestCase {
    func testProductIDsAreUniqueAndNonEmpty() {
        let ids = StoreProductID.allCases.map(\.rawValue)
        XCTAssertEqual(Set(ids).count, ids.count)
        XCTAssertTrue(ids.allSatisfy { $0.hasPrefix("com.foldlight.") })
    }

    func testHintProductsGrantExpectedCredits() {
        XCTAssertEqual(StoreProductID.hints10.grantedHintCredits, 10)
        XCTAssertEqual(StoreProductID.hints50.grantedHintCredits, 50)
        XCTAssertEqual(StoreProductID.starterBundle.grantedHintCredits, 30)
        XCTAssertEqual(StoreProductID.noAds.grantedHintCredits, 0)
    }

    func testOnlyHintPacksAreConsumable() {
        XCTAssertTrue(StoreProductID.hints10.isConsumable)
        XCTAssertTrue(StoreProductID.hints50.isConsumable)
        XCTAssertFalse(StoreProductID.noAds.isConsumable)
        XCTAssertFalse(StoreProductID.starterBundle.isConsumable)
    }
}
