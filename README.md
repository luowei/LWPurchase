# LWPurchase

[![CI Status](https://img.shields.io/travis/luowei/LWPurchase.svg?style=flat)](https://travis-ci.org/luowei/LWPurchase)
[![Version](https://img.shields.io/cocoapods/v/LWPurchase.svg?style=flat)](https://cocoapods.org/pods/LWPurchase)
[![License](https://img.shields.io/cocoapods/l/LWPurchase.svg?style=flat)](https://cocoapods.org/pods/LWPurchase)
[![Platform](https://img.shields.io/cocoapods/p/LWPurchase.svg?style=flat)](https://cocoapods.org/pods/LWPurchase)

**Languages**: [English](./README.md) | [中文版](./README_ZH.md)

## Table of Contents

- [Introduction](#introduction)
- [Key Features](#key-features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Features](#core-features)
- [Advanced Features](#advanced-features)
- [Architecture Design](#architecture-design)
- [Example Project](#example-project)
- [Important Notes](#important-notes)
- [FAQ](#faq)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [License](#license)

## Introduction

LWPurchase is a lightweight, production-ready iOS In-App Purchase (IAP) framework specifically designed for non-consumable products. Built on top of Apple's StoreKit framework, it provides a complete IAP solution that can be integrated into your application with minimal code.

Whether you need to implement a "remove ads" feature, unlock premium content, or offer permanent app upgrades, LWPurchase handles all the complexity of IAP implementation, including product queries, purchase flow, receipt validation, restore purchases, and more.

## Key Features

- **One-Line Integration**: Open the in-app purchase page with just one line of code - perfect for rapid development
- **Non-Consumable Products Focus**: Optimized for permanent unlocks (remove ads, premium features, pro upgrades)
- **Complete Purchase Flow**: Full implementation of purchase, restore, price display, and transaction management
- **Remote Configuration**: Dynamic control of IAP behavior through remote JSON configuration files
- **App Group Support**: Seamlessly synchronize purchase status across app extensions (keyboard, widgets, etc.)
- **Internationalization Ready**: Built-in support for Simplified Chinese, Traditional Chinese, English, Japanese, and more
- **Pre-built UI Components**: Production-ready IAP interface with full customization options
- **Smart Rating System**: Intelligent app rating prompts with configurable trigger logic
- **StoreKit Best Practices**: Built on Apple's recommended patterns for reliable IAP implementation

## Requirements

- iOS 8.0 or higher
- Xcode 11.0 or higher
- Objective-C projects

## Installation

### CocoaPods

LWPurchase is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'LWPurchase'
```

Then run:

```bash
pod install
```

### Carthage

You can also use Carthage to install LWPurchase:

```ruby
github "luowei/LWPurchase"
```

## Quick Start

### Step 1: Basic Integration

Open the in-app purchase page with just one line of code:

```objective-c
#import <LWPurchase/LWPurchaseViewController.h>

// Present the in-app purchase interface
- (IBAction)showPurchaseScreen:(id)sender {
    UINavigationController *navigation = [LWPurchaseViewController navigationViewController];
    [self presentViewController:navigation animated:YES completion:nil];
}
```

That's it! With this single line, you get a fully functional in-app purchase screen with buy and restore functionality.

### Step 2: Configure Your Product

Before using LWPurchase, configure the following macros in `LWPurchaseViewController.h`:

```objective-c
// 1. Set your In-App Purchase Product ID (created in App Store Connect)
#define IAPProductId (@"com.yourcompany.yourapp.remove_ads")

// 2. Configure remote configuration file URL
// Upload the modified IAPConfig.json from Assets directory to your server
#define IAPConfig_URLString @"https://yourserver.com/configs/IAPConfig.json"

// 3. (Optional) Configure App Group for sharing purchase status with extensions
#define AppGroupIdentifer @"group.com.yourcompany.yourapp"
```

**Important**: Make sure your Product ID matches exactly with the one configured in App Store Connect.

### Step 3: Set Up Configuration File

The `IAPConfig.json` configuration file structure:

```json
{
  "data": [
    {
      "APP内购买": [
        {
          "icon": "purchase",
          "title": "Purchase",
          "actionName": "buyAction"
        },
        {
          "icon": "restore",
          "title": "Restore Purchase",
          "actionName": "restoreAction"
        }
      ]
    }
  ],
  "purchaseConfig": {
    "needPurchase": true,           // Whether in-app purchase is required
    "hidePurchaseEntry": false,     // Whether to hide purchase entry
    "needKeyboardPurchase": true,   // Whether keyboard requires purchase
    "tryRatingTriggerCount": 30,    // Trigger rating after X uses
    "ratedTriggerCount": 100        // Remind rated users after X uses
  }
}
```

**Configuration Parameters Explained**:

| Parameter | Type | Description |
|-----------|------|-------------|
| `needPurchase` | Boolean | Master switch to enable/disable IAP functionality |
| `hidePurchaseEntry` | Boolean | Hide purchase UI entry points in the app |
| `needKeyboardPurchase` | Boolean | Require purchase for keyboard extension features |
| `tryRatingTriggerCount` | Integer | Show rating prompt after N app launches |
| `ratedTriggerCount` | Integer | Show rating prompt again after N launches for users who already rated |

This remote configuration allows you to dynamically control IAP behavior without releasing app updates.

## Core Features

### 1. Purchase Management

LWPurchase is built on Apple's StoreKit framework, providing complete purchase flow management with robust error handling and transaction verification.

#### StoreManager - Product Information

The `StoreManager` class handles communication with App Store to retrieve product details:

```objective-c
// Fetch product information from App Store
[[StoreManager sharedInstance] fetchProductInformationForIds:@[IAPProductId]];

// Get localized product title
NSString *title = [[StoreManager sharedInstance] titleMatchingProductIdentifier:IAPProductId];
```

#### StoreObserver - Transaction Handling

The `StoreObserver` class implements the purchase and restore flow:

```objective-c
// Initiate a purchase transaction
[[StoreObserver sharedInstance] buy:product];

// Restore all previous purchases
[[StoreObserver sharedInstance] restore];

// Restore a specific product
[[StoreObserver sharedInstance] restoreWithProduct:product];
```

#### Transaction Status Notifications

Monitor purchase status changes:

```objective-c
// Listen for IAP notifications
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(handlePurchaseNotification:)
                                             name:IAPPurchaseNotification
                                           object:nil];

- (void)handlePurchaseNotification:(NSNotification *)notification {
    StoreObserver *observer = [StoreObserver sharedInstance];

    switch (observer.status) {
        case IAPPurchaseSucceeded:
            // Purchase succeeded
            break;
        case IAPPurchaseFailed:
            // Purchase failed
            break;
        case IAPRestoredSucceeded:
            // Restore succeeded
            break;
        case IAPRestoredFailed:
            // Restore failed
            break;
        default:
            break;
    }
}
```

### 2. Purchase Status Check

Use the `LWPurchaseHelper` class to verify purchase status anywhere in your app:

```objective-c
#import <LWPurchase/LWPurchaseHelper.h>

// Check if user has purchased the product
BOOL isPurchased = [LWPurchaseHelper isPurchased];

// Check if IAP is required (based on remote config)
BOOL needPurchase = [LWPurchaseHelper isNeedPurchase];

// Check if purchase UI entry should be hidden (based on remote config)
BOOL hidePurchaseEntry = [LWPurchaseHelper hidePurchaseEntry];
```

### 3. Price Display and Localization

Retrieve localized pricing from App Store:

```objective-c
// Fetch and display product price asynchronously
[LWPurchaseHelper reloadAppPriceWithCompleteBlock:^(double price) {
    NSLog(@"Product price: $%.2f", price);
    // Update your UI with the localized price
}];
```

The price is automatically formatted according to the user's locale and App Store region.

### 4. App Rating System

Intelligent rating prompt system to encourage user reviews:

```objective-c
// Trigger app rating prompt
[LWPurchaseHelper showRating];
```

**Rating Logic**:
- Shows rating prompt after `tryRatingTriggerCount` app launches (configurable)
- For users who already rated, prompts again after `ratedTriggerCount` launches
- Uses iOS native `SKStoreReviewController` for seamless integration

### 5. Data Persistence

Convenient UserDefaults wrapper with App Group support:

```objective-c
// Save value (supports App Group)
[LWPurchaseHelper setValue:@YES key:@"myKey"];

// Get value (supports App Group)
id value = [LWPurchaseHelper getValueByKey:@"myKey"];

// Use UserDefaults
[LWPurchaseHelper setUserDefaultValue:@YES withKey:@"myKey"];
id defaultValue = [LWPurchaseHelper getUserDefaultValueByKey:@"myKey"];
```

## Advanced Features

### App Group Support for Extensions

Share purchase status seamlessly between your main app and app extensions (keyboard, widgets, etc.):

**Setup Steps**:

1. **Enable App Groups** in Xcode:
   - Select your main app target → Capabilities → App Groups → ON
   - Select your extension target → Capabilities → App Groups → ON

2. **Create App Group ID**:
   - Add a new App Group: `group.com.yourcompany.yourapp`
   - Ensure both targets use the same App Group ID

3. **Configure in LWPurchase**:
   ```objective-c
   #define AppGroupIdentifer @"group.com.yourcompany.yourapp"
   ```

Now your extension can check purchase status using the same methods:
```objective-c
// In your keyboard extension or widget
BOOL isPurchased = [LWPurchaseHelper isPurchased];
```

### Date Utility Methods

Built-in date comparison utilities for time-based features:

```objective-c
// Check if current date is after a specific date
BOOL isAfter = [LWPurchaseHelper isAfterDate:@"2024-01-01"];

// Calculate days between two dates
NSInteger days = [LWPurchaseHelper daysBetweenDate:@"2024-01-01"
                                           andDate:@"2024-12-31"];
```

### UI Helper Utilities

Pre-built UI components for common IAP interactions:

```objective-c
// Show toast message
[MyPurchaseUIHelper showToastAlert:@"Purchase successful"];

// Show HUD loading indicator
[MyPurchaseUIHelper showHUDLoading];
[MyPurchaseUIHelper hideHUDLoading];

// Show HUD with message
[MyPurchaseUIHelper showHUDWithMessage:@"Processing..."];

// Get screen size
CGSize screenSize = [MyPurchaseUIHelper fixedScreenSize];

// Check if purchased
BOOL isPurchased = [MyPurchaseUIHelper checkIsPurchase];
```

## Architecture Design

LWPurchase follows a clean, modular architecture built on Apple's StoreKit framework.

### Core Classes

#### 1. LWPurchaseViewController
**Purpose**: Main UI controller providing the in-app purchase interface

**Responsibilities**:
- Presents purchase and restore purchase UI
- Manages user interactions and button states
- Handles interface updates and animations
- Integrates with StoreManager and StoreObserver

#### 2. StoreManager
**Purpose**: Product information manager

**Responsibilities**:
- Communicates with App Store to fetch product information
- Implements `SKProductsRequestDelegate` protocol
- Provides product query and information retrieval API
- Handles product request responses and errors

**Key Methods**:
- `fetchProductInformationForIds:` - Query products from App Store
- `titleMatchingProductIdentifier:` - Get localized product title

#### 3. StoreObserver
**Purpose**: Transaction observer and processor

**Responsibilities**:
- Implements `SKPaymentTransactionObserver` protocol
- Handles complete purchase and restore flow
- Manages transaction states (purchasing, purchased, failed, restored)
- Posts notifications for transaction events
- Completes transactions with App Store

**Key Methods**:
- `buy:` - Initiate purchase transaction
- `restore` - Restore previous purchases
- Transaction state handling for all SKPaymentTransactionState values

#### 4. LWPurchaseHelper
**Purpose**: Utility class with helper functions

**Responsibilities**:
- Purchase status verification
- Remote configuration management
- Data persistence (UserDefaults + App Group)
- Rating prompt logic
- Date utilities

#### 5. MyPurchaseUIHelper
**Purpose**: UI helper utility class

**Responsibilities**:
- HUD loading indicator management
- Toast alert messages
- Screen size utilities
- Purchase status UI checks

### Notification System

LWPurchase uses `NSNotificationCenter` for decoupled event communication:

#### IAPPurchaseNotification
Purchase transaction status updates:

| Notification Constant | Description |
|-----------------------|-------------|
| `IAPPurchaseSucceeded` | Purchase completed successfully |
| `IAPPurchaseFailed` | Purchase transaction failed |
| `IAPRestoredSucceeded` | Restore purchase succeeded |
| `IAPRestoredFailed` | Restore purchase failed |
| `IAPDownloadStarted` | Hosted content download started |
| `IAPDownloadInProgress` | Hosted content downloading |
| `IAPDownloadSucceeded` | Hosted content download complete |
| `IAPDownloadFailed` | Hosted content download failed |

#### IAPProductRequestNotification
Product query status updates:

| Notification Constant | Description |
|-----------------------|-------------|
| `IAPProductsFound` | Valid products returned from App Store |
| `IAPIdentifiersNotFound` | Invalid/non-existent product IDs |
| `IAPProductRequestResponse` | Product request completed |
| `IAPRequestFailed` | Product request failed |

## Dependencies

LWPurchase has minimal dependencies for optimal performance:

| Library | Purpose | License |
|---------|---------|---------|
| **FCAlertView** | Beautiful, customizable alert dialogs | MIT |
| **Masonry** | Auto Layout DSL for clean constraint code | MIT |
| **Reachability** | Network connectivity detection | BSD |
| **LWHUD** | Loading indicator and progress views | MIT |

These dependencies are automatically installed when using CocoaPods or Carthage.

## Example Project

The example project demonstrates all LWPurchase features with a working implementation.

**Running the Example**:

```bash
# 1. Clone the repository
git clone https://github.com/luowei/LWPurchase.git
cd LWPurchase/Example

# 2. Install dependencies
pod install

# 3. Open the workspace
open LWPurchase.xcworkspace
```

**Before running**:
1. Configure your test Product ID in `LWPurchaseViewController.h`
2. Create a sandbox test account in [App Store Connect](https://appstoreconnect.apple.com/)
3. Run on a real device (IAP doesn't work on simulator)
4. Sign out of your Apple ID and sign in with the sandbox test account

The example includes:
- Complete purchase flow demonstration
- Restore purchase functionality
- Configuration file examples
- UI customization examples

## Important Notes

### 1. Sandbox Testing

Testing IAP requires special setup:

- **Create Sandbox Test Accounts**: Create test accounts in [App Store Connect](https://appstoreconnect.apple.com/) → Users and Access → Sandbox Testers
- **Device Setup**: Test on a real device (IAP doesn't work on simulator)
- **Sign Out**: Sign out of your production Apple ID before testing
- **Sign In**: Use sandbox account when prompted during purchase
- **Important**: Never sign in to sandbox accounts in Settings app - only use them when prompted during purchase

### 2. Product ID Configuration

Product ID is the unique identifier for your IAP product:

- **Exact Match Required**: Product ID in code must match App Store Connect exactly
- **Recommended Format**: Use reverse domain notation: `com.company.appname.productname`
- **Naming Convention**: Use descriptive suffixes like `_NoAds`, `_Premium`, `_ProVersion`
- **Example**: `com.mycompany.myapp.remove_ads`

### 3. Configuration File Best Practices

The remote configuration file enables dynamic control:

- **Host on Your Server**: Upload `IAPConfig.json` to your server for dynamic updates
- **JSON Validation**: Validate JSON syntax before deployment
- **Dynamic Control**: Toggle IAP features without app updates
- **Versioning**: Consider versioning your config file for easier rollbacks
- **HTTPS**: Always use HTTPS for security

### 4. Restore Purchases (Required by Apple)

Apple requires restore functionality for non-consumable products:

- **Requirement**: Must be visible and accessible in your UI
- **User Benefit**: Free restoration after device change or app reinstall
- **Same Apple ID**: Only works with the original purchase Apple ID
- **App Review**: Apple will reject apps without visible restore option

### 5. Privacy and Security

Protect your users and your revenue:

- **Local Storage**: Purchase status stored in UserDefaults (can be cleared)
- **Server Validation**: Consider implementing receipt validation on your server for production
- **App Group Security**: Use App Groups carefully - extensions can access shared data
- **Receipt Validation**: For critical apps, validate receipts with Apple's servers
- **Keychain**: Consider using Keychain for more secure storage

### 6. Internationalization

Built-in language support:

| Language | Code | Supported |
|----------|------|-----------|
| English | en | ✓ |
| Simplified Chinese | zh-Hans | ✓ |
| Traditional Chinese | zh-Hant | ✓ |
| Japanese | ja | ✓ |

The interface automatically adapts to the user's system language. Product names and prices are localized by App Store.

## FAQ

### Q: Why is there no response after attempting to purchase?

**Common Causes**:
1. **Product ID Mismatch**: Verify Product ID in code matches App Store Connect exactly
2. **Product Not Ready**: Ensure product is configured and "Ready to Submit" in App Store Connect
3. **Simulator Testing**: IAP only works on real devices
4. **Network Issues**: Check internet connectivity
5. **Sandbox Account**: Make sure you're using a sandbox test account, not production Apple ID
6. **Wrong Region**: Sandbox accounts are region-locked; ensure account matches device region

### Q: How to verify if purchase was successful?

**Method 1 - Check Purchase Status**:
```objective-c
BOOL purchased = [LWPurchaseHelper isPurchased];
if (purchased) {
    NSLog(@"User has purchased the product");
}
```

**Method 2 - Listen for Notifications**:
```objective-c
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(handlePurchase:)
                                             name:IAPPurchaseNotification
                                           object:nil];
```

### Q: Restore purchase doesn't work?

**Checklist**:
1. **Previous Purchase Required**: Product must have been purchased before
2. **Same Apple ID**: Must use the same Apple ID used for original purchase
3. **Non-Consumable Only**: Restore only works for non-consumable products
4. **Network Connection**: Requires internet to communicate with App Store
5. **Wait for Response**: Restoration can take several seconds

### Q: How to customize the interface?

**Option 1 - Modify Config File**:
```json
// Change button text, icons in IAPConfig.json
{
  "title": "Your Custom Title",
  "icon": "your_custom_icon"
}
```

**Option 2 - Replace Assets**:
- Replace images in the Assets folder with your own

**Option 3 - Subclass**:
```objective-c
@interface MyCustomPurchaseVC : LWPurchaseViewController
@end
// Override methods to customize behavior
```

**Option 4 - Build Custom UI**:
```objective-c
// Use StoreManager and StoreObserver directly
[[StoreManager sharedInstance] fetchProductInformationForIds:@[IAPProductId]];
[[StoreObserver sharedInstance] buy:product];
```

### Q: Does it support subscription products?

**Short Answer**: No, LWPurchase is specifically designed for non-consumable products.

**Why Not Subscriptions**:
- Subscriptions require different transaction handling
- Auto-renewal logic is more complex
- Subscription status checking is different
- Receipt validation is more involved

**Recommendation**: For subscriptions, use dedicated libraries or Apple's StoreKit 2 (iOS 15+).

### Q: Can I test IAP on the iOS Simulator?

**No**. In-App Purchases require:
- Real iOS device
- Sandbox test account
- Internet connection

The simulator will always fail IAP requests.

### Q: How to handle "Cannot connect to iTunes Store" error?

**Solutions**:
1. **Check Network**: Ensure device has internet
2. **Sign Out**: Sign out of production Apple ID in Settings
3. **Don't Pre-sign**: Don't sign into sandbox account in Settings - wait for purchase prompt
4. **Sandbox Status**: Check [Apple System Status](https://developer.apple.com/system-status/) for sandbox issues
5. **Wait**: Sometimes sandbox is slow; wait and retry

### Q: Do I need a server for receipt validation?

**For Basic Apps**: No, local validation is sufficient for many use cases.

**For High-Value Apps**: Yes, server-side receipt validation is recommended to:
- Prevent jailbreak bypass
- Detect receipt fraud
- Track purchase analytics
- Implement cross-platform purchases

## Changelog

### Version 1.0.0 (Initial Release)

**Features**:
- Complete non-consumable product purchase implementation
- Restore purchases functionality
- Ready-to-use UI interface with navigation controller
- Remote JSON configuration for dynamic control
- App Group support for sharing purchase status with extensions
- Multi-language support (English, Simplified Chinese, Traditional Chinese, Japanese)
- Intelligent app rating system with configurable triggers
- HUD loading indicators and toast messages
- Price display from App Store
- Comprehensive notification system for transaction events

**Supported Platforms**:
- iOS 8.0+
- iPhone, iPad, iPod touch

**Installation Methods**:
- CocoaPods
- Carthage

## Contributing

Contributions are welcome and appreciated! Whether you find a bug, have a feature request, or want to improve documentation, your input helps make LWPurchase better.

**How to Contribute**:

1. **Report Issues**: Found a bug? [Open an issue](https://github.com/luowei/LWPurchase/issues) with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - iOS version and device info

2. **Suggest Features**: Have an idea? Create a feature request issue describing:
   - The feature and its benefits
   - Potential use cases
   - Any implementation ideas

3. **Submit Pull Requests**:
   ```bash
   # Fork the repository on GitHub

   # Clone your fork
   git clone https://github.com/YOUR_USERNAME/LWPurchase.git
   cd LWPurchase

   # Create a feature branch
   git checkout -b feature/your-feature-name

   # Make your changes and commit
   git commit -m "Add: Brief description of your changes"

   # Push to your fork
   git push origin feature/your-feature-name

   # Open a Pull Request on GitHub
   ```

**Contribution Guidelines**:
- Follow existing code style and conventions
- Test your changes thoroughly
- Update documentation if needed
- Keep commits focused and well-described

## Author

**luowei**
Email: [luowei@wodedata.com](mailto:luowei@wodedata.com)

## License

LWPurchase is available under the MIT license. See the [LICENSE](LICENSE) file for more details.

```
Copyright (c) 2019 luowei <luowei@wodedata.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

## Resources

### Documentation
- [GitHub Repository](https://github.com/luowei/LWPurchase) - Source code and issues
- [CocoaPods Page](https://cocoapods.org/pods/LWPurchase) - Installation and versions
- [API Documentation](https://github.com/luowei/LWPurchase/wiki) - Detailed API reference

### Apple Resources
- [StoreKit Framework](https://developer.apple.com/documentation/storekit) - Official StoreKit documentation
- [App Store Connect](https://appstoreconnect.apple.com/) - Manage products and test accounts
- [In-App Purchase Guide](https://developer.apple.com/in-app-purchase/) - Apple's IAP best practices
- [Receipt Validation](https://developer.apple.com/documentation/appstorereceipts) - Receipt validation guide

### Testing & Debugging
- [Sandbox Testing](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox) - Official sandbox guide
- [Apple System Status](https://developer.apple.com/system-status/) - Check sandbox availability

## Acknowledgments

LWPurchase is built with the help of these excellent open source projects:

- [**FCAlertView**](https://github.com/krispenney/FCAlertView) - Beautiful alert dialogs
- [**Masonry**](https://github.com/SnapKit/Masonry) - Elegant Auto Layout DSL
- [**Reachability**](https://github.com/tonymillion/Reachability) - Network status monitoring
- [**LWHUD**](https://github.com/luowei/LWHUD) - Loading and progress indicators

Special thanks to all contributors and users who help improve LWPurchase.

---

**Need Help?**

- Questions? [Open an issue](https://github.com/luowei/LWPurchase/issues)
- Email: [luowei@wodedata.com](mailto:luowei@wodedata.com)

---

Made with ❤️ by [luowei](https://github.com/luowei)
