//
// Created by luowei on 2025.
// Copyright (c) 2025 luowei. All rights reserved.
//

import Foundation

// MARK: - Configuration Keys
struct LWPurchaseKeys {
    static let isPurchasedSuccessedUser = "Key_isPurchasedSuccessedUser"
    static let ratingTriggerCount = "Key_RatingTriggerCount"
    static let appPrice = "appPrice"
    static let needPurchase = "needPurchase"
    static let hidePurchaseEntry = "hidePurchaseEntry"
    static let tryRatingTriggerCount = "tryRatingTriggerCount"
    static let ratedTriggerCount = "ratedTriggerCount"
    static let currentTriggerCount = "currentTriggerCount"
}

// MARK: - Configuration URLs
struct LWPurchaseURLs {
    // Configure your product ID here
    static let productId = "com.wodedata.WBInputMethod_NoAds"

    // Configure your IAP config URL here
    static let iapConfigURL = "http://wodedata.com/MyResource/WBInput/data_iapconfig.json"

    // App lookup URL for pricing info
    static let appLookup = "http://itunes.apple.com/cn/lookup?id=1335365550"

    // App reviews URL
    static let appReviews = "https://itunes.apple.com/cn/rss/customerreviews/id=1522850307/json"

    // App Group Identifier
    static let appGroupIdentifier = "group.com.wodedata.WBInputMethod"

    // Reference date
    static let afterDate = "2020-12-05"
}

// MARK: - Dispatch Helper
func dispatchMainAsyncSafe(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async {
            block()
        }
    }
}

// MARK: - Bundle Helper
class LWPurchaseBundleHelper {
    static func getBundle(for object: AnyObject) -> Bundle {
        if let bundlePath = Bundle(for: type(of: object)).path(forResource: "LWPurchase", ofType: "bundle"),
           let bundle = Bundle(path: bundlePath) {
            return bundle
        } else if let bundlePath = Bundle.main.path(forResource: "LWPurchase", ofType: "bundle"),
                  let bundle = Bundle(path: bundlePath) {
            return bundle
        }
        return Bundle.main
    }
}
