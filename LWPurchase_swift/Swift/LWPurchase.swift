//
// LWPurchase.swift
// LWPurchase
//
// Created by luowei on 2025.
// Copyright (c) 2025 luowei. All rights reserved.
//
// Main public interface for LWPurchase Swift library

import Foundation
import StoreKit
import SwiftUI

// MARK: - LWPurchase Public Interface

/// Main class for LWPurchase library
/// Provides a Swift-friendly interface for in-app purchases
public final class LWPurchase {

    // MARK: - Singleton
    public static let shared = LWPurchase()

    private init() {
        // Initialize observers
        _ = StoreManager.shared
        _ = StoreObserver.shared
    }

    // MARK: - Configuration

    /// Configure the library with product ID and other settings
    /// - Parameters:
    ///   - productId: The in-app purchase product identifier
    ///   - appGroupIdentifier: Optional app group identifier for shared data
    public func configure(productId: String? = nil, appGroupIdentifier: String? = nil) {
        // Configuration is handled through LWPurchaseURLs struct
        // This method is provided for future extensibility
    }

    // MARK: - Purchase Status

    /// Check if the user has already purchased
    public var isPurchased: Bool {
        return LWPurchaseHelper.isPurchased()
    }

    /// Check if in-app purchase is needed
    public var isNeedPurchase: Bool {
        return LWPurchaseHelper.isNeedPurchase()
    }

    /// Check if purchase entry should be hidden
    public var hidePurchaseEntry: Bool {
        return LWPurchaseHelper.hidePurchaseEntry()
    }

    // MARK: - View Controllers

    /// Get a UIKit navigation controller with purchase view (iOS 13+)
    @available(iOS 13.0, *)
    public func navigationController() -> UINavigationController? {
        return LWPurchaseViewController.navigationViewController()
    }

    /// Get a UIKit purchase view controller (iOS 13+)
    @available(iOS 13.0, *)
    public func viewController() -> UIViewController? {
        return LWPurchaseViewController.viewController()
    }

    // MARK: - SwiftUI Views

    /// Get a SwiftUI purchase view (iOS 13+)
    @available(iOS 13.0, *)
    public func purchaseView() -> some View {
        return LWPurchaseView()
    }

    /// Get a modern SwiftUI purchase view (iOS 14+)
    @available(iOS 14.0, *)
    public func modernPurchaseView() -> some View {
        return ModernPurchaseView()
    }

    // MARK: - Purchase Actions

    /// Fetch products from App Store
    public func fetchProducts(completion: @escaping ([SKProduct]) -> Void) {
        var observer: NSObjectProtocol?
        observer = NotificationCenter.default.addObserver(
            forName: .IAPProductRequest,
            object: nil,
            queue: .main
        ) { notification in
            if let obs = observer {
                NotificationCenter.default.removeObserver(obs)
            }
            if let storeManager = notification.object as? StoreManager {
                completion(storeManager.availableProducts)
            }
        }

        StoreManager.shared.fetchProductInformation(for: [LWPurchaseURLs.productId])
    }

    /// Purchase a product
    public func purchase(_ product: SKProduct) {
        StoreObserver.shared.buy(product)
    }

    /// Restore previous purchases
    public func restorePurchases() {
        StoreObserver.shared.restore()
    }

    // MARK: - Configuration Management

    /// Reload purchase configuration from network
    public func reloadConfiguration() {
        LWPurchaseHelper.reloadNeedPurchaseConfig()
    }

    /// Reload app price information
    public func reloadAppPrice(completion: @escaping (Double) -> Void) {
        LWPurchaseHelper.reloadAppPrice(completion: completion)
    }

    // MARK: - Rating

    /// Show rating prompt if conditions are met
    public func showRating() {
        LWPurchaseHelper.showRating()
    }

    /// Show rating prompt immediately (iOS 10.3+)
    @available(iOS 10.3, *)
    public func requestReview() {
        SKStoreReviewController.requestReview()
    }

    // MARK: - Utilities

    /// Check if current date is after specified date
    public func isAfter(date: String) -> Bool {
        return LWPurchaseHelper.isAfter(date: date)
    }

    /// Calculate days between two dates
    public func daysBetween(from: String, to: String) -> Int {
        return LWPurchaseHelper.daysBetween(from: from, to: to)
    }

    /// Check if user can make payments
    public var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
}

// MARK: - Async/Await Support
@available(iOS 13.0, *)
extension LWPurchase {

    /// Fetch products asynchronously (iOS 15+)
    @available(iOS 15.0, *)
    public func fetchProducts() async throws -> [SKProduct] {
        return try await LWPurchaseManager.shared.fetchProductsAsync()
    }

    /// Purchase product asynchronously (iOS 15+)
    @available(iOS 15.0, *)
    public func purchase(_ product: SKProduct) async throws {
        try await LWPurchaseManager.shared.purchaseAsync(product)
    }

    /// Restore purchases asynchronously (iOS 15+)
    @available(iOS 15.0, *)
    public func restorePurchases() async throws {
        try await LWPurchaseManager.shared.restorePurchasesAsync()
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    /// Posted when purchase status changes
    public static let LWPurchaseStatusChanged = Notification.Name("LWPurchaseStatusChangedNotification")
}

// MARK: - Public Typealiases
public typealias LWProduct = SKProduct
public typealias LWPaymentTransaction = SKPaymentTransaction

// MARK: - Error Types
public enum LWPurchaseError: Error {
    case productNotFound
    case purchaseFailed(String)
    case restoreFailed(String)
    case cannotMakePayments
    case unknown

    public var localizedDescription: String {
        switch self {
        case .productNotFound:
            return "Product not found in App Store"
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .restoreFailed(let message):
            return "Restore failed: \(message)"
        case .cannotMakePayments:
            return "In-app purchases are disabled on this device"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
