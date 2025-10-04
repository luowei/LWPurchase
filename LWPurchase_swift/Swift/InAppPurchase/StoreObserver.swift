//
// StoreObserver.swift
// LWPurchase
//
// Created by luowei on 2025.
// Copyright (c) 2025 luowei. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - Purchase Notification Status
enum IAPPurchaseNotificationStatus {
    case purchaseFailed        // Purchase unsuccessful
    case purchaseSucceeded     // Purchase successful
    case restoredFailed        // Restore unsuccessful
    case restoredSucceeded     // Restore successful
    case downloadStarted       // Download started
    case downloadInProgress    // Download in progress
    case downloadFailed        // Download failed
    case downloadSucceeded     // Download successful
}

// MARK: - Notification Name
extension Notification.Name {
    static let IAPPurchase = Notification.Name("IAPPurchaseNotification")
}

// MARK: - Store Observer
class StoreObserver: NSObject {

    // MARK: - Singleton
    static let shared = StoreObserver()

    // MARK: - Properties
    var status: IAPPurchaseNotificationStatus = .purchaseFailed
    var message: String = ""
    var downloadProgress: Float = 0.0
    var purchasedID: String?
    var product: SKProduct?

    var purchasedTransactions: [SKPaymentTransaction] = []
    var restoredTransactions: [SKPaymentTransaction] = []

    // MARK: - Private
    private override init() {
        super.init()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    // MARK: - Public Methods

    /// Check if there are purchased products
    func hasPurchasedProducts() -> Bool {
        return !purchasedTransactions.isEmpty
    }

    /// Check if there are restored products
    func hasRestoredProducts() -> Bool {
        return !restoredTransactions.isEmpty
    }

    /// Purchase a product
    func buy(_ product: SKProduct) {
        SKPaymentQueue.default().add(self)
        self.product = product

        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    /// Restore purchases with specific product
    func restore(with product: SKProduct) {
        SKPaymentQueue.default().add(self)
        self.product = product
        restoredTransactions.removeAll()
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    /// Restore all purchases
    func restore() {
        SKPaymentQueue.default().add(self)
        restoredTransactions.removeAll()
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    // MARK: - Private Methods

    private func completeTransaction(_ transaction: SKPaymentTransaction, forStatus status: IAPPurchaseNotificationStatus) {
        self.status = status

        // Don't send notification if user cancelled
        if transaction.error?.code != SKError.paymentCancelled.rawValue {
            NotificationCenter.default.post(name: .IAPPurchase, object: self)
        }

        if status == .downloadStarted {
            // Start downloading hosted content
            if let downloads = transaction.downloads {
                SKPaymentQueue.default().start(downloads)
            }
        } else if status == .purchaseSucceeded || status == .restoredSucceeded || status == .downloadSucceeded {
            // Finish transaction
            SKPaymentQueue.default().finishTransaction(transaction)
        } else {
            // Finish failed transactions
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }

    private func finishDownloadTransaction(_ transaction: SKPaymentTransaction) {
        var allAssetsDownloaded = true

        // Check if all downloads are complete
        if let downloads = transaction.downloads {
            for download in downloads {
                if download.state != .cancelled &&
                   download.state != .failed &&
                   download.state != .finished {
                    allAssetsDownloaded = false
                    break
                }
            }
        }

        if allAssetsDownloaded {
            status = .downloadSucceeded
            SKPaymentQueue.default().finishTransaction(transaction)
            NotificationCenter.default.post(name: .IAPPurchase, object: self)

            if restoredTransactions.contains(transaction) {
                status = .restoredSucceeded
                NotificationCenter.default.post(name: .IAPPurchase, object: self)
            }
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension StoreObserver: SKPaymentTransactionObserver {

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break

            case .deferred:
                print("StoreObserver: Allow the user to continue using your app")
                break

            case .purchased:
                purchasedID = transaction.payment.productIdentifier
                purchasedTransactions.append(transaction)
                print("StoreObserver: Deliver content for \(transaction.payment.productIdentifier)")

                if let downloads = transaction.downloads, !downloads.isEmpty {
                    completeTransaction(transaction, forStatus: .downloadStarted)
                } else {
                    completeTransaction(transaction, forStatus: .purchaseSucceeded)
                }

            case .restored:
                purchasedID = transaction.payment.productIdentifier
                restoredTransactions.append(transaction)
                print("StoreObserver: Restore content for \(transaction.payment.productIdentifier)")

                if let downloads = transaction.downloads, !downloads.isEmpty {
                    completeTransaction(transaction, forStatus: .downloadStarted)
                } else {
                    completeTransaction(transaction, forStatus: .restoredSucceeded)
                }

            case .failed:
                message = "Purchase of \(transaction.payment.productIdentifier) failed."
                if let error = transaction.error {
                    message = error.localizedDescription
                }
                completeTransaction(transaction, forStatus: .purchaseFailed)

            @unknown default:
                break
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        for download in downloads {
            switch download.state {
            case .active:
                status = .downloadInProgress
                purchasedID = download.transaction.payment.productIdentifier
                downloadProgress = Float(download.progress) * 100
                NotificationCenter.default.post(name: .IAPPurchase, object: self)

            case .cancelled:
                if let url = download.contentURL {
                    try? FileManager.default.removeItem(at: url)
                }
                finishDownloadTransaction(download.transaction)

            case .failed:
                if let url = download.contentURL {
                    try? FileManager.default.removeItem(at: url)
                }
                finishDownloadTransaction(download.transaction)

            case .paused:
                print("StoreObserver: Download was paused")

            case .finished:
                print("StoreObserver: Download finished at \(download.contentURL?.absoluteString ?? "")")
                finishDownloadTransaction(download.transaction)

            case .waiting:
                print("StoreObserver: Download waiting")
                SKPaymentQueue.default().start([download])

            @unknown default:
                break
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("StoreObserver: \(transaction.payment.productIdentifier) was removed from the payment queue")
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if (error as NSError).code != SKError.paymentCancelled.rawValue {
            status = .restoredFailed
            message = error.localizedDescription
            NotificationCenter.default.post(name: .IAPPurchase, object: self)
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("StoreObserver: All restorable transactions have been processed")

        // If no transactions in queue, initiate purchase
        if queue.transactions.isEmpty {
            if let product = product {
                buy(product)
            }
        } else {
            // Check if product is in transactions, otherwise initiate purchase
            let hasProduct = queue.transactions.contains { $0.payment.productIdentifier == product?.productIdentifier }
            if !hasProduct, let product = product {
                buy(product)
            }
        }
    }
}
