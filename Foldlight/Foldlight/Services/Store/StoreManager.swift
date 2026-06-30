//
//  StoreManager.swift
//  Foldlight
//
//  StoreKit 2 purchase manager. It loads real App Store Connect products when
//  available, verifies transactions locally, and exposes a fallback catalog so
//  development builds still have a complete shop surface before product setup.
//

import Foundation
import StoreKit

enum StoreProductID: String, CaseIterable, Identifiable, Sendable {
    case noAds = "com.foldlight.noads"
    case starterBundle = "com.foldlight.starterbundle"
    case hints10 = "com.foldlight.hints.10"
    case hints50 = "com.foldlight.hints.50"
    case crystalCaveSkin = "com.foldlight.skin.crystalcave"
    case stardustSkin = "com.foldlight.skin.stardust"
    case shadowRealmSkin = "com.foldlight.skin.shadowrealm"
    case challengePassSeasonOne = "com.foldlight.challengepass.s1"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .noAds: return "No Ads"
        case .starterBundle: return "Starter Bundle"
        case .hints10: return "10 Hints"
        case .hints50: return "50 Hints"
        case .crystalCaveSkin: return "Crystal Cave Skin"
        case .stardustSkin: return "Stardust Skin"
        case .shadowRealmSkin: return "Shadow Realm Skin"
        case .challengePassSeasonOne: return "Challenge Pass"
        }
    }

    var subtitle: String {
        switch self {
        case .noAds: return "Remove optional rewarded ads when they arrive."
        case .starterBundle: return "No Ads, 30 hints, and a premium board skin."
        case .hints10: return "A small pack for harder generated puzzles."
        case .hints50: return "Best value hint reserve for expert runs."
        case .crystalCaveSkin: return "A brighter prism-board look."
        case .stardustSkin: return "A soft celestial tile set."
        case .shadowRealmSkin: return "High-contrast midnight panels."
        case .challengePassSeasonOne: return "Seasonal challenges and early cosmetics."
        }
    }

    var fallbackPrice: String {
        switch self {
        case .noAds: return "$2.99"
        case .starterBundle: return "$4.99"
        case .hints10: return "$0.99"
        case .hints50: return "$3.99"
        case .crystalCaveSkin, .stardustSkin, .shadowRealmSkin: return "$1.99"
        case .challengePassSeasonOne: return "$2.99/mo"
        }
    }

    var systemImage: String {
        switch self {
        case .noAds: return "nosign"
        case .starterBundle: return "gift.fill"
        case .hints10, .hints50: return "lightbulb.fill"
        case .crystalCaveSkin, .stardustSkin, .shadowRealmSkin: return "paintpalette.fill"
        case .challengePassSeasonOne: return "sparkles"
        }
    }

    var grantedHintCredits: Int {
        switch self {
        case .hints10: return 10
        case .hints50: return 50
        case .starterBundle: return 30
        default: return 0
        }
    }

    var isConsumable: Bool {
        switch self {
        case .hints10, .hints50: return true
        default: return false
        }
    }
}

enum StorePurchaseStatus: Equatable, Sendable {
    case purchased(StoreProductID)
    case pending
    case cancelled
    case unavailable
    case failed(String)
}

@MainActor
final class StoreManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    deinit {
        updatesTask?.cancel()
    }

    func start() {
        guard updatesTask == nil else { return }
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await MainActor.run {
                        self.purchasedProductIDs.insert(transaction.productID)
                    }
                    await transaction.finish()
                }
            }
        }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: StoreProductID.allCases.map(\.rawValue))
            errorMessage = nil
            await syncEntitlements()
        } catch {
            products = []
            errorMessage = "Store products are not configured for this build yet."
        }
    }

    func displayPrice(for productID: StoreProductID) -> String {
        product(for: productID)?.displayPrice ?? productID.fallbackPrice
    }

    func product(for productID: StoreProductID) -> Product? {
        products.first { $0.id == productID.rawValue }
    }

    func purchase(_ productID: StoreProductID) async -> StorePurchaseStatus {
        guard let product = product(for: productID) else { return .unavailable }

        do {
            switch try await product.purchase() {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
                return .purchased(productID)
            case .pending:
                return .pending
            case .userCancelled:
                return .cancelled
            @unknown default:
                return .failed("Unknown purchase result.")
            }
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    func syncEntitlements() async {
        var entitlements: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                entitlements.insert(transaction.productID)
            }
        }
        purchasedProductIDs = entitlements
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw StoreError.failedVerification
        }
    }
}

private enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "The transaction could not be verified."
        }
    }
}
