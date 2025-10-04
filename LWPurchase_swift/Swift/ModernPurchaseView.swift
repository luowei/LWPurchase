//
// ModernPurchaseView.swift
// LWPurchase
//
// Created by luowei on 2025.
// Copyright (c) 2025 luowei. All rights reserved.
//

import SwiftUI
import StoreKit

@available(iOS 14.0, *)
public struct ModernPurchaseView: View {

    @StateObject private var purchaseManager = LWPurchaseManager.shared
    @Environment(\.presentationMode) var presentationMode

    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection

                        // Purchase Status
                        if purchaseManager.isPurchased {
                            purchasedSection
                        } else {
                            // Products Section
                            productsSection

                            // Actions Section
                            actionsSection
                        }

                        // Rating Section
                        if shouldShowRating {
                            ratingSection
                        }

                        Spacer()
                    }
                    .padding()
                }

                // Loading Overlay
                if purchaseManager.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(10)
                        )
                }
            }
            .navigationTitle("In-App Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                purchaseManager.fetchProducts()
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onChange(of: purchaseManager.errorMessage) { error in
                if let error = error {
                    alertTitle = "Error"
                    alertMessage = error
                    showingAlert = true
                }
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            Text("Premium Features")
                .font(.title2)
                .fontWeight(.bold)

            Text("Unlock all features and remove limitations")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }

    // MARK: - Purchased Section
    private var purchasedSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("Thank You!")
                .font(.title)
                .fontWeight(.bold)

            Text("You have already purchased premium features")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Products Section
    private var productsSection: some View {
        VStack(spacing: 12) {
            ForEach(purchaseManager.products, id: \.productIdentifier) { product in
                ProductCard(product: product) {
                    purchaseManager.purchase(product)
                }
            }
        }
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                purchaseManager.restorePurchases()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                    Text("Restore Purchases")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Rating Section
    private var ratingSection: some View {
        VStack(spacing: 12) {
            Divider()

            Button(action: {
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                }
            }) {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Rate This App")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Computed Properties
    private var shouldShowRating: Bool {
        return LWPurchaseHelper.isNeedPurchase() &&
               !LWPurchaseHelper.isPurchased() &&
               LWPurchaseHelper.isAfter(date: LWPurchaseURLs.afterDate)
    }
}

// MARK: - Product Card
@available(iOS 14.0, *)
struct ProductCard: View {
    let product: SKProduct
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.localizedTitle)
                        .font(.headline)

                    Text(product.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(priceString)
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }

            Button(action: action) {
                Text("Purchase")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var priceString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? "\(product.price)"
    }
}

// MARK: - Preview
@available(iOS 14.0, *)
struct ModernPurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        ModernPurchaseView()
    }
}
