//
//  ShopView.swift
//  Foldlight
//
//  Optional monetization surface backed by StoreKit 2. Purchases are never
//  required to solve puzzles; hints and cosmetics are convenience/identity items.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        ShopContent(store: environment.storeManager, environment: environment)
            .navigationTitle(AppRoute.shop.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ShopContent: View {
    @ObservedObject var store: StoreManager
    @ObservedObject var environment: AppEnvironment

    @State private var purchasingID: StoreProductID?
    @State private var message: String?

    var body: some View {
        ScreenScaffold {
            ScrollView {
                VStack(alignment: .leading, spacing: FoldlightSpacing.lg) {
                    balance

                    if let error = store.errorMessage {
                        InfoBanner(systemImage: "shippingbox", message: error)
                    }

                    VStack(spacing: FoldlightSpacing.md) {
                        ForEach(StoreProductID.allCases) { productID in
                            ProductRow(
                                productID: productID,
                                price: store.displayPrice(for: productID),
                                isAvailable: store.product(for: productID) != nil,
                                isOwned: isOwned(productID),
                                isPurchasing: purchasingID == productID
                            ) {
                                Task { await purchase(productID) }
                            }
                        }
                    }

                    PrimaryButton("Restore Purchases", systemImage: "arrow.clockwise") {
                        Task { await restore() }
                    }
                }
                .padding(FoldlightSpacing.lg)
            }
        }
        .task {
            store.start()
            await store.refresh()
            await environment.analytics.track(.screenViewed("shop"))
        }
        .alert("Shop", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
            Button("OK", role: .cancel) { message = nil }
        } message: {
            Text(message ?? "")
        }
    }

    private var balance: some View {
        HStack(spacing: FoldlightSpacing.md) {
            ShopBalanceChip(icon: "sparkle", value: "\(environment.profile.lightFragments)", label: "Fragments", tint: FoldlightColor.fragment)
            ShopBalanceChip(icon: "lightbulb.fill", value: "\(environment.profile.hintCredits)", label: "Hints", tint: FoldlightColor.primary)
        }
    }

    private func isOwned(_ productID: StoreProductID) -> Bool {
        guard !productID.isConsumable else { return false }
        return environment.profile.ownedProductIDs.contains(productID.rawValue) ||
            store.purchasedProductIDs.contains(productID.rawValue)
    }

    private func purchase(_ productID: StoreProductID) async {
        guard purchasingID == nil else { return }
        purchasingID = productID
        defer { purchasingID = nil }

        switch await store.purchase(productID) {
        case .purchased(let product):
            await environment.fulfill(product)
            message = "\(product.title) is ready."
        case .pending:
            message = "Purchase pending approval."
        case .cancelled:
            break
        case .unavailable:
            message = "This product is not configured for the current StoreKit build."
        case .failed(let reason):
            message = reason
        }
    }

    private func restore() async {
        await store.syncEntitlements()
        for productID in StoreProductID.allCases where store.purchasedProductIDs.contains(productID.rawValue) {
            await environment.fulfill(productID)
        }
        message = "Purchases restored."
    }
}

private struct ProductRow: View {
    let productID: StoreProductID
    let price: String
    let isAvailable: Bool
    let isOwned: Bool
    let isPurchasing: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: FoldlightSpacing.md) {
            Image(systemName: productID.systemImage)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(FoldlightColor.primary)
                .frame(width: 48, height: 48)
                .background(FoldlightColor.primary.opacity(0.14), in: RoundedRectangle(cornerRadius: FoldlightRadius.sm))

            VStack(alignment: .leading, spacing: FoldlightSpacing.xxs) {
                Text(productID.title)
                    .font(FoldlightTypography.headline())
                    .foregroundStyle(FoldlightColor.textPrimary)
                Text(productID.subtitle)
                    .font(FoldlightTypography.caption())
                    .foregroundStyle(FoldlightColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: FoldlightSpacing.sm)

            Button(action: action) {
                if isPurchasing {
                    ProgressView()
                        .tint(FoldlightColor.background)
                } else {
                    Text(buttonTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }
            .font(FoldlightTypography.caption())
            .foregroundStyle(isAvailable && !isOwned ? FoldlightColor.background : FoldlightColor.textSecondary)
            .frame(width: 86, height: 40)
            .background(
                isAvailable && !isOwned ? FoldlightColor.primary : FoldlightColor.border.opacity(0.35),
                in: RoundedRectangle(cornerRadius: FoldlightRadius.sm)
            )
            .disabled(!isAvailable || isOwned || isPurchasing)
        }
        .padding(FoldlightSpacing.md)
        .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: FoldlightRadius.md)
                .stroke(FoldlightColor.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(productID.title), \(price), \(isOwned ? "owned" : productID.subtitle)")
    }

    private var buttonTitle: String {
        if isOwned { return "Owned" }
        if !isAvailable { return "Soon" }
        return price
    }
}

private struct ShopBalanceChip: View {
    let icon: String
    let value: String
    let label: String
    let tint: Color

    var body: some View {
        HStack(spacing: FoldlightSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: FoldlightSpacing.xxs) {
                Text(value)
                    .font(FoldlightTypography.numeric())
                    .foregroundStyle(FoldlightColor.textPrimary)
                Text(label)
                    .font(FoldlightTypography.caption())
                    .foregroundStyle(FoldlightColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(FoldlightSpacing.md)
        .background(FoldlightColor.surface, in: RoundedRectangle(cornerRadius: FoldlightRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: FoldlightRadius.md)
                .stroke(FoldlightColor.border, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        ShopView()
    }
    .environmentObject(AppEnvironment.live())
}
