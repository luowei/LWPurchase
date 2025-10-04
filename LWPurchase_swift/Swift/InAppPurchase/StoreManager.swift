//
// StoreManager.swift
// LWPurchase
//
// Created by luowei on 2025.
// Copyright (c) 2025 luowei. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - Product Model
class ProductModel {
    var name: String
    var elements: [SKProduct]

    init(name: String, elements: [SKProduct]) {
        self.name = name
        self.elements = elements
    }
}

// MARK: - Product Request Status
enum IAPProductRequestStatus {
    case productsFound          // Valid products found
    case identifiersNotFound   // Invalid product identifiers
    case productRequestResponse // Returns both valid and invalid products
    case requestFailed         // Product request failed
}

// MARK: - Notification Name
extension Notification.Name {
    static let IAPProductRequest = Notification.Name("IAPProductRequestNotification")
}

// MARK: - Store Manager
class StoreManager: NSObject {

    // MARK: - Singleton
    static let shared = StoreManager()

    // MARK: - Properties
    var status: IAPProductRequestStatus = .requestFailed
    var availableProducts: [SKProduct] = []
    var invalidProductIds: [String] = []
    var responseModels: [ProductModel] = []
    var errorMessage: String?

    // MARK: - Private
    private override init() {
        super.init()
    }

    // MARK: - Public Methods

    /// Fetch product information from App Store
    func fetchProductInformation(for productIds: [String]) {
        responseModels.removeAll()

        let productIdentifiers = Set(productIds)
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }

    /// Get product title matching a product identifier
    func titleMatching(productIdentifier identifier: String) -> String? {
        return availableProducts.first { $0.productIdentifier == identifier }?.localizedTitle
    }
}

// MARK: - SKProductsRequestDelegate
extension StoreManager: SKProductsRequestDelegate {

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("StoreManager: Received product response")

        // Available products
        if !response.products.isEmpty {
            let model = ProductModel(name: "AVAILABLE PRODUCTS", elements: response.products)
            responseModels.append(model)
            availableProducts = response.products
        }

        // Invalid product identifiers
        if !response.invalidProductIdentifiers.isEmpty {
            invalidProductIds = response.invalidProductIdentifiers
            print("Invalid product identifiers: \(response.invalidProductIdentifiers)")
        }

        status = .productRequestResponse
        NotificationCenter.default.post(name: .IAPProductRequest, object: self)
    }

    func requestDidFinish(_ request: SKRequest) {
        print("StoreManager: Request finished")
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("StoreManager: Product request failed - \(error.localizedDescription)")
        errorMessage = error.localizedDescription
        status = .requestFailed
        NotificationCenter.default.post(name: .IAPProductRequest, object: self)
    }
}
