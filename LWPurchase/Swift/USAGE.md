# LWPurchase Swift Usage Guide

This document provides examples of how to use the Swift/SwiftUI version of LWPurchase.

## Table of Contents
- [Installation](#installation)
- [Basic Setup](#basic-setup)
- [UIKit Integration](#uikit-integration)
- [SwiftUI Integration](#swiftui-integration)
- [Advanced Usage](#advanced-usage)
- [API Reference](#api-reference)

## Installation

### CocoaPods
```ruby
pod 'LWPurchase'
```

### Swift Package Manager
Add the package dependency to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/luowei/LWPurchase.git", from: "1.0.0")
]
```

## Basic Setup

### Configuration
Configure your product ID and app group in `LWPurchaseConfig.swift`:

```swift
struct LWPurchaseURLs {
    static let productId = "com.yourcompany.yourapp.premium"
    static let appGroupIdentifier = "group.com.yourcompany.yourapp"
}
```

## UIKit Integration

### Presenting Purchase View Controller

```swift
import UIKit
import LWPurchase

class ViewController: UIViewController {

    @IBAction func showPurchaseButtonTapped(_ sender: UIButton) {
        if #available(iOS 13.0, *) {
            if let navController = LWPurchase.shared.navigationController() {
                present(navController, animated: true)
            }
        }
    }

    // Or push onto existing navigation stack
    func pushPurchaseView() {
        if #available(iOS 13.0, *) {
            if let vc = LWPurchase.shared.viewController() {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
```

### Using UIHelper

```swift
// Check purchase status
if LWPurchaseUIHelper.checkIsPurchase() {
    // User has purchased, unlock features
} else {
    // Show purchase prompt
}

// Show HUD messages
LWPurchaseUIHelper.showHUD(message: "Processing...")
LWPurchaseUIHelper.showHUDLoading()
LWPurchaseUIHelper.hideHUDLoading()
```

## SwiftUI Integration

### Basic Purchase View (iOS 13+)

```swift
import SwiftUI
import LWPurchase

struct ContentView: View {
    @State private var showPurchase = false

    var body: some View {
        Button("Show Purchase") {
            showPurchase = true
        }
        .sheet(isPresented: $showPurchase) {
            if #available(iOS 13.0, *) {
                LWPurchase.shared.purchaseView()
            }
        }
    }
}
```

### Modern Purchase View (iOS 14+)

```swift
import SwiftUI
import LWPurchase

struct ContentView: View {
    @State private var showPurchase = false

    var body: some View {
        Button("Show Premium Features") {
            showPurchase = true
        }
        .sheet(isPresented: $showPurchase) {
            if #available(iOS 14.0, *) {
                LWPurchase.shared.modernPurchaseView()
            }
        }
    }
}
```

### Using ObservableObject (iOS 13+)

```swift
import SwiftUI
import LWPurchase

struct FeatureView: View {
    @StateObject private var purchaseManager = LWPurchaseManager.shared

    var body: some View {
        VStack {
            if purchaseManager.isPurchased {
                Text("Premium Features Unlocked!")
                    .foregroundColor(.green)
            } else {
                Text("Upgrade to Premium")

                Button("Purchase") {
                    purchaseManager.fetchProducts()
                }
            }
        }
    }
}
```

## Advanced Usage

### Callback-based Purchase (iOS 13+)

```swift
import LWPurchase

class PurchaseService {
    func buyPremium() {
        LWPurchase.shared.fetchProducts { products in
            guard let product = products.first else {
                print("No products available")
                return
            }

            LWPurchase.shared.purchase(product)
        }
    }

    func restore() {
        LWPurchase.shared.restorePurchases()
    }
}
```

### Async/Await Purchase (iOS 15+)

```swift
import LWPurchase

@available(iOS 15.0, *)
class PurchaseService {
    func buyPremium() async {
        do {
            let products = try await LWPurchase.shared.fetchProducts()
            guard let product = products.first else {
                print("No products available")
                return
            }

            try await LWPurchase.shared.purchase(product)
            print("Purchase successful!")
        } catch {
            print("Purchase failed: \(error.localizedDescription)")
        }
    }

    func restorePurchases() async {
        do {
            try await LWPurchase.shared.restorePurchases()
            print("Restore successful!")
        } catch {
            print("Restore failed: \(error.localizedDescription)")
        }
    }
}
```

### Combine-based Purchase (iOS 13+)

```swift
import LWPurchase
import Combine

@available(iOS 13.0, *)
class PurchaseViewModel: ObservableObject {
    @Published var isPurchased = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let manager = LWPurchaseManager.shared

    init() {
        manager.$isPurchased
            .assign(to: &$isPurchased)

        manager.$errorMessage
            .assign(to: &$errorMessage)
    }

    func purchase() {
        manager.fetchProducts()

        manager.$products
            .first { !$0.isEmpty }
            .sink { [weak self] products in
                if let product = products.first {
                    self?.manager.purchase(product)
                }
            }
            .store(in: &cancellables)
    }
}
```

### Checking Purchase Status

```swift
// Simple check
if LWPurchase.shared.isPurchased {
    // Unlock premium features
}

// Check if purchases are needed
if LWPurchase.shared.isNeedPurchase {
    // Show purchase prompt
}

// Check if purchase entry should be hidden
if !LWPurchase.shared.hidePurchaseEntry {
    // Show purchase button
}
```

### Rating Integration

```swift
// Show rating based on triggers
LWPurchase.shared.showRating()

// Request review immediately (iOS 10.3+)
if #available(iOS 10.3, *) {
    LWPurchase.shared.requestReview()
}
```

## API Reference

### LWPurchase (Main Class)

```swift
// Singleton instance
LWPurchase.shared

// Properties
.isPurchased: Bool          // Check if user has purchased
.isNeedPurchase: Bool       // Check if purchase is needed
.hidePurchaseEntry: Bool    // Check if entry should be hidden
.canMakePayments: Bool      // Check if device can make payments

// Methods
.configure(productId:appGroupIdentifier:)  // Configure library
.navigationController() -> UINavigationController?  // Get UIKit nav controller
.viewController() -> UIViewController?              // Get UIKit view controller
.purchaseView() -> some View                        // Get SwiftUI view
.modernPurchaseView() -> some View                  // Get modern SwiftUI view
.fetchProducts(completion:)                         // Fetch products
.purchase(_:)                                       // Purchase product
.restorePurchases()                                 // Restore purchases
.reloadConfiguration()                              // Reload config
.reloadAppPrice(completion:)                        // Reload price
.showRating()                                       // Show rating
.requestReview()                                    // Request review
```

### LWPurchaseManager (iOS 13+)

```swift
// Singleton instance
LWPurchaseManager.shared

// Published Properties
@Published var isPurchased: Bool
@Published var isLoading: Bool
@Published var products: [SKProduct]
@Published var errorMessage: String?

// Methods
.fetchProducts()                    // Fetch products
.purchase(_:)                       // Purchase product
.restorePurchases()                 // Restore purchases
.checkPurchaseStatus()              // Check status
.reloadConfiguration()              // Reload config

// Async Methods (iOS 15+)
.fetchProductsAsync() async throws -> [SKProduct]
.purchaseAsync(_:) async throws
.restorePurchasesAsync() async throws
```

### LWPurchaseHelper

```swift
// Static utility methods
LWPurchaseHelper.isPurchased() -> Bool
LWPurchaseHelper.isNeedPurchase() -> Bool
LWPurchaseHelper.hidePurchaseEntry() -> Bool
LWPurchaseHelper.isAfter(date:) -> Bool
LWPurchaseHelper.daysBetween(from:to:) -> Int
LWPurchaseHelper.showRating()
LWPurchaseHelper.reloadAppPrice(completion:)
LWPurchaseHelper.reloadNeedPurchaseConfig()
```

## Migration from Objective-C

### Objective-C
```objc
#import "LWPurchaseViewController.h"

LWPurchaseViewController *vc = [LWPurchaseViewController viewController];
[self.navigationController pushViewController:vc animated:YES];

BOOL isPurchased = [LWPurchaseHelper isPurchased];
```

### Swift
```swift
import LWPurchase

if let vc = LWPurchase.shared.viewController() {
    navigationController?.pushViewController(vc, animated: true)
}

let isPurchased = LWPurchase.shared.isPurchased
```

## Notes

- Minimum iOS version: iOS 13.0 for basic Swift support
- Modern SwiftUI views require iOS 14.0+
- Async/await support requires iOS 15.0+
- Configure product IDs in `LWPurchaseConfig.swift`
- All UI updates are automatically dispatched to the main thread
