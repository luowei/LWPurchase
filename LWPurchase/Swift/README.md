# LWPurchase - Swift/SwiftUI Implementation

This directory contains the Swift/SwiftUI version of the LWPurchase iOS library for in-app purchases.

## Overview

The Swift implementation provides a modern, type-safe interface for handling in-app purchases in iOS applications. It maintains compatibility with the original Objective-C API while offering modern Swift features like Combine, async/await, and SwiftUI views.

## Architecture

### Core Files

#### Configuration
- **LWPurchaseConfig.swift** - Configuration constants, bundle helpers, and utility functions
  - Product IDs, URLs, and app group identifiers
  - Dispatch helpers for thread-safe UI updates
  - Bundle helper for accessing resources

#### Helpers
- **LWPurchaseHelper.swift** - Core business logic and utilities
  - Purchase status management
  - Date utilities
  - App Store price fetching
  - Rating triggers
  - UserDefaults and App Group storage
  - Configuration loading from network/local

#### Store Integration
- **InAppPurchase/StoreManager.swift** - Product information management
  - Fetches product information from App Store
  - Manages product models and responses
  - Handles product request states
  - SKProductsRequestDelegate implementation

- **InAppPurchase/StoreObserver.swift** - Transaction observer
  - Handles purchase transactions
  - Manages restore purchases
  - Download management for hosted content
  - SKPaymentTransactionObserver implementation

### UI Components

#### SwiftUI Views
- **LWPurchaseView.swift** - Basic SwiftUI purchase view (iOS 13+)
  - List-based purchase interface
  - Product display and purchase actions
  - Restore purchases functionality
  - Rating integration

- **ModernPurchaseView.swift** - Modern SwiftUI purchase view (iOS 14+)
  - Card-based UI with modern design
  - Enhanced user experience
  - Loading states and error handling
  - Premium feature showcase

#### UIKit Compatibility
- **LWPurchaseViewController.swift** - UIKit wrapper for SwiftUI views
  - UIHostingController integration
  - Navigation controller support
  - Backward compatibility with UIKit apps
  - UIKit helper utilities (LWPurchaseUIHelper)

### Advanced Features

#### Reactive Programming
- **LWPurchaseManager.swift** - ObservableObject for Combine/SwiftUI (iOS 13+)
  - Published properties for state management
  - Combine publishers for reactive updates
  - Async/await support (iOS 15+)
  - Centralized purchase state

#### Public API
- **LWPurchase.swift** - Main public interface
  - Singleton pattern for easy access
  - Unified API for all purchase operations
  - UIKit and SwiftUI view factories
  - Error handling types
  - Notification extensions

## File Structure

```
Swift/
├── LWPurchase.swift                  # Main public API
├── LWPurchaseConfig.swift            # Configuration & constants
├── LWPurchaseHelper.swift            # Core utilities
├── LWPurchaseManager.swift           # Combine/async manager
├── LWPurchaseView.swift              # SwiftUI view (iOS 13+)
├── LWPurchaseViewController.swift    # UIKit wrapper
├── ModernPurchaseView.swift          # Modern SwiftUI view (iOS 14+)
├── InAppPurchase/
│   ├── StoreManager.swift            # Product management
│   └── StoreObserver.swift           # Transaction observer
├── USAGE.md                          # Usage examples
└── README.md                         # This file
```

## Key Features

### Modern Swift Patterns
- ✅ Swift 5.0+ with modern syntax
- ✅ Type-safe enumerations
- ✅ Protocol-oriented design
- ✅ Value types where appropriate
- ✅ Proper error handling

### SwiftUI Support
- ✅ Declarative UI components
- ✅ @StateObject and @Published properties
- ✅ Environment support
- ✅ Previews for development

### Reactive Programming
- ✅ Combine framework integration
- ✅ Published properties
- ✅ Notification publishers
- ✅ Async/await support (iOS 15+)

### Backward Compatibility
- ✅ UIKit wrapper available
- ✅ Similar API to Objective-C version
- ✅ Easy migration path

### Thread Safety
- ✅ Main thread dispatching
- ✅ Safe concurrent operations
- ✅ Notification-based communication

## Requirements

- **Minimum iOS Version**: iOS 13.0
- **Modern SwiftUI Views**: iOS 14.0+
- **Async/Await Support**: iOS 15.0+
- **Swift Version**: 5.0+
- **Xcode**: 12.0+

## Usage

See [USAGE.md](USAGE.md) for detailed examples and integration guide.

### Quick Start

```swift
import LWPurchase

// Check purchase status
if LWPurchase.shared.isPurchased {
    // User has purchased
}

// Show purchase view (SwiftUI)
.sheet(isPresented: $showPurchase) {
    LWPurchase.shared.modernPurchaseView()
}

// Show purchase view (UIKit)
if let navController = LWPurchase.shared.navigationController() {
    present(navController, animated: true)
}

// Purchase with async/await (iOS 15+)
Task {
    do {
        let products = try await LWPurchase.shared.fetchProducts()
        try await LWPurchase.shared.purchase(products.first!)
    } catch {
        print("Error: \(error)")
    }
}
```

## API Comparison

### Objective-C → Swift

| Objective-C | Swift |
|-------------|-------|
| `[LWPurchaseHelper isPurchased]` | `LWPurchase.shared.isPurchased` |
| `[LWPurchaseViewController viewController]` | `LWPurchase.shared.viewController()` |
| `[StoreManager sharedInstance]` | `StoreManager.shared` |
| `[StoreObserver sharedInstance]` | `StoreObserver.shared` |
| Blocks/Delegates | Async/await, Combine, Closures |

## Notifications

### Product Request
- **Name**: `.IAPProductRequest`
- **Object**: `StoreManager` instance
- **Use**: Notifies when product information is received

### Purchase Status
- **Name**: `.IAPPurchase`
- **Object**: `StoreObserver` instance
- **Use**: Notifies when purchase/restore status changes

## Error Handling

```swift
enum LWPurchaseError: Error {
    case productNotFound
    case purchaseFailed(String)
    case restoreFailed(String)
    case cannotMakePayments
    case unknown
}
```

## Best Practices

1. **Always check purchase status before showing premium features**
   ```swift
   if LWPurchase.shared.isPurchased {
       // Show premium content
   }
   ```

2. **Use async/await for modern apps (iOS 15+)**
   ```swift
   Task {
       try await LWPurchase.shared.purchase(product)
   }
   ```

3. **Use ObservableObject for SwiftUI**
   ```swift
   @StateObject private var manager = LWPurchaseManager.shared
   ```

4. **Handle errors appropriately**
   ```swift
   do {
       try await purchase(product)
   } catch let error as LWPurchaseError {
       // Handle specific error
   }
   ```

## Migration Guide

### From Objective-C

1. Import the Swift module:
   ```swift
   import LWPurchase
   ```

2. Replace class methods with singleton:
   ```swift
   // Before
   [LWPurchaseHelper isPurchased]

   // After
   LWPurchase.shared.isPurchased
   ```

3. Use Swift-native types:
   ```swift
   // Before
   NSArray<SKProduct *> *products

   // After
   let products: [SKProduct]
   ```

## License

Same as the main LWPurchase library.

## Author

Created by luowei, 2025
Based on the original Objective-C implementation (2019)

## Notes

- All UI operations are automatically dispatched to the main thread
- The library uses UserDefaults and App Group for data persistence
- Network configuration can be loaded dynamically
- Rating prompts follow Apple's guidelines and restrictions
