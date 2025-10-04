//
// LWPurchaseManager.swift
// LWPurchase
//
// Created by luowei on 2025.
// Copyright (c) 2025 luowei. All rights reserved.
//

import Foundation
import Combine
import StoreKit

@available(iOS 13.0, *)
public class LWPurchaseManager: ObservableObject {

    // MARK: - Singleton
    public static let shared = LWPurchaseManager()

    // MARK: - Published Properties
    @Published public private(set) var isPurchased: Bool = false
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var products: [SKProduct] = []
    @Published public private(set) var errorMessage: String?

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    private init() {
        setupObservers()
        checkPurchaseStatus()
    }

    // MARK: - Public Methods

    /// Fetch products from App Store
    public func fetchProducts() {
        isLoading = true
        errorMessage = nil

        StoreManager.shared.fetchProductInformation(for: [LWPurchaseURLs.productId])
    }

    /// Purchase a product
    public func purchase(_ product: SKProduct) {
        isLoading = true
        errorMessage = nil

        StoreObserver.shared.buy(product)
    }

    /// Restore purchases
    public func restorePurchases() {
        isLoading = true
        errorMessage = nil

        StoreObserver.shared.restore()
    }

    /// Check current purchase status
    public func checkPurchaseStatus() {
        isPurchased = LWPurchaseHelper.isPurchased()
    }

    /// Reload configuration from network
    public func reloadConfiguration() {
        LWPurchaseHelper.reloadNeedPurchaseConfig()
    }

    // MARK: - Private Methods

    private func setupObservers() {
        // Observe product request notifications
        NotificationCenter.default.publisher(for: .IAPProductRequest)
            .compactMap { $0.object as? StoreManager }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] storeManager in
                self?.handleProductRequest(storeManager)
            }
            .store(in: &cancellables)

        // Observe purchase notifications
        NotificationCenter.default.publisher(for: .IAPPurchase)
            .compactMap { $0.object as? StoreObserver }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] storeObserver in
                self?.handlePurchaseNotification(storeObserver)
            }
            .store(in: &cancellables)
    }

    private func handleProductRequest(_ storeManager: StoreManager) {
        isLoading = false

        if storeManager.status == .productRequestResponse {
            products = storeManager.availableProducts
            errorMessage = nil
        } else if storeManager.status == .requestFailed {
            errorMessage = storeManager.errorMessage
        }
    }

    private func handlePurchaseNotification(_ storeObserver: StoreObserver) {
        isLoading = false

        switch storeObserver.status {
        case .purchaseSucceeded, .restoredSucceeded, .downloadSucceeded:
            LWPurchaseHelper.setValue(true, forKey: LWPurchaseKeys.isPurchasedSuccessedUser)
            isPurchased = true
            errorMessage = nil

        case .purchaseFailed, .restoredFailed, .downloadFailed:
            LWPurchaseHelper.setValue(false, forKey: LWPurchaseKeys.isPurchasedSuccessedUser)
            errorMessage = storeObserver.message
            isPurchased = false

        case .downloadInProgress:
            // Handle download progress if needed
            break

        default:
            break
        }
    }
}

// MARK: - Async/Await Support
@available(iOS 15.0, *)
extension LWPurchaseManager {

    /// Fetch products asynchronously
    public func fetchProductsAsync() async throws -> [SKProduct] {
        return try await withCheckedThrowingContinuation { continuation in
            var observer: NSObjectProtocol?

            observer = NotificationCenter.default.addObserver(
                forName: .IAPProductRequest,
                object: nil,
                queue: .main
            ) { notification in
                if let obs = observer {
                    NotificationCenter.default.removeObserver(obs)
                }

                guard let storeManager = notification.object as? StoreManager else {
                    continuation.resume(throwing: NSError(domain: "LWPurchase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                    return
                }

                if storeManager.status == .productRequestResponse {
                    continuation.resume(returning: storeManager.availableProducts)
                } else {
                    continuation.resume(throwing: NSError(domain: "LWPurchase", code: -2, userInfo: [NSLocalizedDescriptionKey: storeManager.errorMessage ?? "Unknown error"]))
                }
            }

            fetchProducts()
        }
    }

    /// Purchase product asynchronously
    public func purchaseAsync(_ product: SKProduct) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            var observer: NSObjectProtocol?

            observer = NotificationCenter.default.addObserver(
                forName: .IAPPurchase,
                object: nil,
                queue: .main
            ) { notification in
                if let obs = observer {
                    NotificationCenter.default.removeObserver(obs)
                }

                guard let storeObserver = notification.object as? StoreObserver else {
                    continuation.resume(throwing: NSError(domain: "LWPurchase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                    return
                }

                switch storeObserver.status {
                case .purchaseSucceeded, .downloadSucceeded:
                    continuation.resume()
                case .purchaseFailed, .downloadFailed:
                    continuation.resume(throwing: NSError(domain: "LWPurchase", code: -3, userInfo: [NSLocalizedDescriptionKey: storeObserver.message]))
                default:
                    break
                }
            }

            purchase(product)
        }
    }

    /// Restore purchases asynchronously
    public func restorePurchasesAsync() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            var observer: NSObjectProtocol?

            observer = NotificationCenter.default.addObserver(
                forName: .IAPPurchase,
                object: nil,
                queue: .main
            ) { notification in
                if let obs = observer {
                    NotificationCenter.default.removeObserver(obs)
                }

                guard let storeObserver = notification.object as? StoreObserver else {
                    continuation.resume(throwing: NSError(domain: "LWPurchase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                    return
                }

                switch storeObserver.status {
                case .restoredSucceeded:
                    continuation.resume()
                case .restoredFailed:
                    continuation.resume(throwing: NSError(domain: "LWPurchase", code: -4, userInfo: [NSLocalizedDescriptionKey: storeObserver.message]))
                default:
                    break
                }
            }

            restorePurchases()
        }
    }
}
