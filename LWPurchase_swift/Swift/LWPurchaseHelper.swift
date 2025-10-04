//
// Created by luowei on 2025.
// Copyright (c) 2025 luowei. All rights reserved.
//

import Foundation
import StoreKit

class LWPurchaseHelper {

    // MARK: - Singleton
    static let shared = LWPurchaseHelper()

    private init() {}

    // MARK: - Purchase Config

    /// Refresh purchase configuration
    static func refreshPurchaseConfig(_ configDict: [String: Any]) {
        setValue(configDict[LWPurchaseKeys.needPurchase], forKey: LWPurchaseKeys.needPurchase)
        setValue(configDict[LWPurchaseKeys.hidePurchaseEntry], forKey: LWPurchaseKeys.hidePurchaseEntry)
        setValue(configDict[LWPurchaseKeys.tryRatingTriggerCount], forKey: LWPurchaseKeys.tryRatingTriggerCount)
        setValue(configDict[LWPurchaseKeys.ratedTriggerCount], forKey: LWPurchaseKeys.ratedTriggerCount)
    }

    // MARK: - Date Helpers

    /// Check if current date is after the specified date string (format: yyyy-MM-dd)
    static func isAfter(date dateString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let currentDate = formatter.string(from: Date())
        let days = daysBetween(from: dateString, to: currentDate)
        return days >= 0
    }

    /// Calculate days between two date strings
    static func daysBetween(from: String, to: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        guard let fromDate = formatter.date(from: from),
              let toDate = formatter.date(from: to) else {
            return 0
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: fromDate, to: toDate)
        return components.day ?? 0
    }

    // MARK: - Purchase Status

    /// Check if user has already purchased
    static func isPurchased() -> Bool {
        let isPurchasedValue = getValue(forKey: LWPurchaseKeys.isPurchasedSuccessedUser) as? Bool
        var isPurchased = isPurchasedValue ?? false

        if !isPurchased {
            // If purchase is not needed, it means already purchased
            isPurchased = !isNeedPurchase()
        }

        return isPurchased
    }

    /// Check if purchase is needed
    static func isNeedPurchase() -> Bool {
        let hidePurchaseEntry = (getValue(forKey: LWPurchaseKeys.hidePurchaseEntry) as? Bool) ?? false
        if hidePurchaseEntry {
            return false
        }

        var isNeedPurchase = (getValue(forKey: LWPurchaseKeys.needPurchase) as? Bool) ?? false
        if !isNeedPurchase {
            let appPrice = (getValue(forKey: LWPurchaseKeys.appPrice) as? Double) ?? 0
            isNeedPurchase = appPrice <= 3 // Enable IAP automatically if price <= 3
        }

        return isNeedPurchase
    }

    /// Check if purchase entry should be hidden
    static func hidePurchaseEntry() -> Bool {
        return (getValue(forKey: LWPurchaseKeys.hidePurchaseEntry) as? Bool) ?? false
    }

    // MARK: - App Price

    /// Reload app price from App Store
    static func reloadAppPrice(completion: @escaping (Double) -> Void) {
        guard let url = URL(string: LWPurchaseURLs.appLookup) else {
            completion(0)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(0)
                return
            }

            do {
                if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = dict["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let price = firstResult["price"] {
                    let dbPrice: Double
                    if let priceNum = price as? NSNumber {
                        dbPrice = priceNum.doubleValue
                        setValue(price, forKey: LWPurchaseKeys.appPrice)
                    } else if let priceStr = price as? String {
                        dbPrice = Double(priceStr) ?? 0
                        setValue(price, forKey: LWPurchaseKeys.appPrice)
                    } else {
                        dbPrice = 0
                    }
                    completion(dbPrice)
                } else {
                    completion(0)
                }
            } catch {
                completion(0)
            }
        }
        task.resume()
    }

    // MARK: - Rating

    /// Show rating prompt if conditions are met
    static func showRating() {
        let tryTriggerCount = (getValue(forKey: LWPurchaseKeys.tryRatingTriggerCount) as? Int) ?? 50
        let ratedTriggerCount = (getValue(forKey: LWPurchaseKeys.ratedTriggerCount) as? Int) ?? 200
        var currentTriggerCount = (getValue(forKey: LWPurchaseKeys.currentTriggerCount) as? Int) ?? 0

        var shouldTrigger = currentTriggerCount == tryTriggerCount
        if !shouldTrigger {
            shouldTrigger = (currentTriggerCount - tryTriggerCount) % ratedTriggerCount == 0
        }

        if shouldTrigger {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }

        currentTriggerCount += 1
        setValue(currentTriggerCount, forKey: LWPurchaseKeys.currentTriggerCount)
    }

    // MARK: - Config Loading

    /// Reload purchase config from network
    static func reloadNeedPurchaseConfig() {
        guard let url = URL(string: LWPurchaseURLs.iapConfigURL) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                loadPurchaseConfigFromLocal()
                return
            }

            do {
                if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let purchaseConfig = dict["purchaseConfig"] as? [String: Any] {
                    DispatchQueue.main.async {
                        refreshPurchaseConfig(purchaseConfig)
                    }
                } else {
                    loadPurchaseConfigFromLocal()
                }
            } catch {
                loadPurchaseConfigFromLocal()
            }
        }
        task.resume()
    }

    /// Load purchase config from local bundle
    static func loadPurchaseConfigFromLocal() {
        guard let filePath = Bundle(for: LWPurchaseHelper.self).path(forResource: "IAPConfig", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            DispatchQueue.main.async {
                let defaultConfig: [String: Any] = [
                    LWPurchaseKeys.needPurchase: true,
                    LWPurchaseKeys.hidePurchaseEntry: false,
                    LWPurchaseKeys.tryRatingTriggerCount: 20,
                    LWPurchaseKeys.ratedTriggerCount: 100
                ]
                refreshPurchaseConfig(defaultConfig)
            }
            return
        }

        do {
            if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let purchaseConfig = dict["purchaseConfig"] as? [String: Any] {
                DispatchQueue.main.async {
                    refreshPurchaseConfig(purchaseConfig)
                }
            }
        } catch {
            print("Failed to parse local config: \(error)")
        }
    }

    // MARK: - UserDefaults Storage

    /// Get value from storage (checks app group first, then standard UserDefaults)
    static func getValue(forKey key: String) -> Any? {
        if let value = getAppGroupValue(forKey: key) {
            return value
        }

        let value = getUserDefaultValue(forKey: key)
        if let value = value {
            setAppGroupValue(value, forKey: key)
        }
        return value
    }

    /// Set value to storage (both standard UserDefaults and app group)
    static func setValue(_ value: Any?, forKey key: String) {
        setUserDefaultValue(value, forKey: key)
        setAppGroupValue(value, forKey: key)
    }

    /// Get value from standard UserDefaults
    static func getUserDefaultValue(forKey key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }

    /// Set value to standard UserDefaults
    static func setUserDefaultValue(_ value: Any?, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

    /// Get value from app group UserDefaults
    static func getAppGroupValue(forKey key: String) -> Any? {
        guard let userDefaults = UserDefaults(suiteName: LWPurchaseURLs.appGroupIdentifier) else {
            return nil
        }
        return userDefaults.object(forKey: key)
    }

    /// Set value to app group UserDefaults
    static func setAppGroupValue(_ value: Any?, forKey key: String) {
        guard let userDefaults = UserDefaults(suiteName: LWPurchaseURLs.appGroupIdentifier) else {
            return
        }
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
}
