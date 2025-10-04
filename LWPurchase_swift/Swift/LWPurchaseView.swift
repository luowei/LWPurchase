//
// LWPurchaseView.swift
// LWPurchase
//
// Created by luowei on 2025.
// Copyright (c) 2025 luowei. All rights reserved.
//

import SwiftUI
import StoreKit

// MARK: - Purchase Item Model
struct PurchaseItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let actionName: String?
    let appId: String?
}

struct PurchaseSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [PurchaseItem]
}

// MARK: - Purchase View
@available(iOS 13.0, *)
public struct LWPurchaseView: View {

    @Environment(\.presentationMode) var presentationMode
    @State private var sections: [PurchaseSection] = []
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showLoading = false
    @State private var iapProduct: SKProduct?
    @State private var isRestoreRequest = false
    @State private var tapCount = 0

    public init() {}

    public var body: some View {
        NavigationView {
            List {
                ForEach(sections) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.items) { item in
                            Button(action: {
                                handleItemAction(item)
                            }) {
                                HStack {
                                    if !item.icon.isEmpty {
                                        Image(item.icon, bundle: LWPurchaseBundleHelper.getBundle(for: self as AnyObject))
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                    Text(getDisplayTitle(for: item))
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(localizedString("In-App Purchase"), displayMode: .inline)
            .navigationBarItems(leading: Button(localizedString("Close")) {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                loadSections()
                registerNotifications()
            }
            .onDisappear {
                unregisterNotifications()
            }
            .onTapGesture(count: 5) {
                handleDebugTap()
            }
            .overlay(
                Group {
                    if showLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(width: 100, height: 100)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                    }
                }
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Private Methods

    private func loadSections() {
        var newSections: [PurchaseSection] = []

        // Main purchase section
        let purchaseItems = [
            PurchaseItem(icon: "purchase", title: localizedString("Purchase"), actionName: "buy", appId: nil),
            PurchaseItem(icon: "restore", title: localizedString("Restore"), actionName: "restore", appId: nil)
        ]
        newSections.append(PurchaseSection(title: "APP内购买", items: purchaseItems))

        // Add review section if needed
        if LWPurchaseHelper.isNeedPurchase() &&
           !LWPurchaseHelper.isPurchased() &&
           LWPurchaseHelper.isAfter(date: LWPurchaseURLs.afterDate) {
            let reviewItem = PurchaseItem(icon: "review", title: localizedString("Review"), actionName: "review", appId: nil)
            newSections.insert(PurchaseSection(title: "好评鼓励", items: [reviewItem]), at: 0)
        }

        sections = newSections
    }

    private func getDisplayTitle(for item: PurchaseItem) -> String {
        if item.actionName == "buy" && LWPurchaseHelper.isPurchased() {
            return localizedString("Thanks for Your Support")
        }
        return item.title
    }

    private func handleItemAction(_ item: PurchaseItem) {
        guard let actionName = item.actionName else { return }

        switch actionName {
        case "buy":
            if LWPurchaseHelper.isPurchased() {
                return
            }
            buyAction()
        case "restore":
            restoreAction()
        case "review":
            reviewAction()
        default:
            break
        }
    }

    private func handleDebugTap() {
        tapCount += 1
        if tapCount >= 5 {
            tapCount = 0
            let isPurchased = LWPurchaseHelper.isPurchased()
            LWPurchaseHelper.setValue(!isPurchased, forKey: LWPurchaseKeys.isPurchasedSuccessedUser)
            loadSections()
        }
    }

    // MARK: - Purchase Actions

    private func buyAction() {
        isRestoreRequest = false
        let isPurchased = LWPurchaseHelper.getValue(forKey: LWPurchaseKeys.isPurchasedSuccessedUser) as? Bool ?? false

        if !isPurchased {
            fetchProductInformation()
        } else {
            showMessage(localizedString("Have been purchased"))
        }
    }

    private func restoreAction() {
        isRestoreRequest = true
        let isPurchased = LWPurchaseHelper.getValue(forKey: LWPurchaseKeys.isPurchasedSuccessedUser) as? Bool ?? false

        if !isPurchased {
            fetchProductInformation()
        } else {
            showMessage(localizedString("Have been purchased"))
        }
    }

    private func reviewAction() {
        if #available(iOS 10.3, *) {
            UIApplication.shared.windows.first?.endEditing(true)
            SKStoreReviewController.requestReview()
        } else {
            let urlString = "itms-apps://itunes.apple.com/app/id1227288468?action=write-review"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }
    }

    private func fetchProductInformation() {
        guard SKPaymentQueue.canMakePayments() else {
            showMessage(localizedString("Purchases Disabled on this device."))
            return
        }

        let productIds = [LWPurchaseURLs.productId]
        StoreManager.shared.fetchProductInformation(for: productIds)
    }

    // MARK: - Notification Handlers

    private func registerNotifications() {
        NotificationCenter.default.addObserver(
            forName: .IAPProductRequest,
            object: nil,
            queue: .main
        ) { [self] notification in
            handleProductRequest(notification)
        }

        NotificationCenter.default.addObserver(
            forName: .IAPPurchase,
            object: nil,
            queue: .main
        ) { [self] notification in
            handlePurchase(notification)
        }
    }

    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: .IAPProductRequest, object: nil)
        NotificationCenter.default.removeObserver(self, name: .IAPPurchase, object: nil)
    }

    private func handleProductRequest(_ notification: Notification) {
        guard let storeManager = notification.object as? StoreManager else { return }

        if storeManager.status == .productRequestResponse {
            for model in storeManager.responseModels {
                if model.name == "AVAILABLE PRODUCTS" {
                    let product = model.elements.first
                    if let product = product, product.productIdentifier == LWPurchaseURLs.productId {
                        iapProduct = product

                        if isRestoreRequest {
                            StoreObserver.shared.restore(with: product)
                        } else {
                            showProductAlert(product)
                        }
                        return
                    }
                }
            }
        }
    }

    private func handlePurchase(_ notification: Notification) {
        guard let storeObserver = notification.object as? StoreObserver else { return }

        switch storeObserver.status {
        case .purchaseFailed:
            LWPurchaseHelper.setValue(false, forKey: LWPurchaseKeys.isPurchasedSuccessedUser)
            showMessage(storeObserver.message)
            loadSections()

        case .purchaseSucceeded, .restoredSucceeded:
            LWPurchaseHelper.setValue(true, forKey: LWPurchaseKeys.isPurchasedSuccessedUser)
            showMessage(storeObserver.message.isEmpty ? localizedString("Purchase Successful") : storeObserver.message)
            loadSections()

        case .restoredFailed:
            LWPurchaseHelper.setValue(false, forKey: LWPurchaseKeys.isPurchasedSuccessedUser)
            showMessage(storeObserver.message)
            loadSections()

        case .downloadSucceeded:
            LWPurchaseHelper.setValue(true, forKey: LWPurchaseKeys.isPurchasedSuccessedUser)
            loadSections()

        default:
            break
        }
    }

    private func showProductAlert(_ product: SKProduct) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale

        let priceString = formatter.string(from: product.price) ?? "\(product.price)"
        let supportText = localizedString("Support Developer")

        alertTitle = product.localizedTitle
        alertMessage = "\(product.localizedDescription)\n\(supportText)\(priceString)"
        showAlert = true

        // Trigger purchase when alert is dismissed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            StoreObserver.shared.buy(product)
        }
    }

    private func showMessage(_ message: String) {
        alertTitle = ""
        alertMessage = message
        showAlert = true
    }

    private func localizedString(_ key: String) -> String {
        let bundle = LWPurchaseBundleHelper.getBundle(for: self as AnyObject)
        return NSLocalizedString(key, tableName: "Local", bundle: bundle, comment: "")
    }
}

// MARK: - Public Factory Methods
@available(iOS 13.0, *)
extension LWPurchaseView {
    /// Create a purchase view wrapped in navigation controller
    public static func navigationView() -> some View {
        if LWPurchaseHelper.hidePurchaseEntry() {
            return AnyView(EmptyView())
        }
        return AnyView(LWPurchaseView())
    }

    /// Create a standalone purchase view
    public static func view() -> some View {
        if LWPurchaseHelper.hidePurchaseEntry() {
            return AnyView(EmptyView())
        }
        return AnyView(LWPurchaseView())
    }
}

// MARK: - Preview
@available(iOS 13.0, *)
struct LWPurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        LWPurchaseView()
    }
}
