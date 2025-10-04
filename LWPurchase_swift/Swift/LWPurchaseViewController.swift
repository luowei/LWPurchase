//
// LWPurchaseViewController.swift
// LWPurchase
//
// Created by luowei on 2025.
// Copyright (c) 2025 luowei. All rights reserved.
//

import UIKit
import SwiftUI
import StoreKit

@available(iOS 13.0, *)
public class LWPurchaseViewController: UIViewController {

    // MARK: - Properties
    public var needPrePurchase: Bool = false
    private var hostingController: UIHostingController<LWPurchaseView>?

    // MARK: - Factory Methods

    /// Create a navigation controller with purchase view
    public static func navigationViewController() -> UINavigationController? {
        if LWPurchaseHelper.hidePurchaseEntry() {
            return nil
        }
        guard let vc = viewController() else { return nil }
        return UINavigationController(rootViewController: vc)
    }

    /// Create a purchase view controller
    public static func viewController() -> LWPurchaseViewController? {
        if LWPurchaseHelper.hidePurchaseEntry() {
            return nil
        }
        return LWPurchaseViewController()
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupHostingController()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if needPrePurchase {
            if LWPurchaseHelper.isPurchased() {
                // Already purchased
            } else {
                // Trigger purchase automatically
                // Note: This would need to be implemented in the SwiftUI view
            }
        }
    }

    // MARK: - Private Methods

    private func setupHostingController() {
        let purchaseView = LWPurchaseView()
        let hosting = UIHostingController(rootView: purchaseView)

        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.frame = view.bounds
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hosting.didMove(toParent: self)

        hostingController = hosting
    }
}

// MARK: - UIKit Helper for backward compatibility
public class LWPurchaseUIHelper: NSObject {

    // MARK: - HUD Methods

    /// Show toast message
    public static func showToast(message: String) {
        DispatchQueue.main.async {
            // For iOS 13+, you might want to use a modern alert or banner
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(alert, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    alert.dismiss(animated: true)
                }
            }
        }
    }

    /// Show HUD with message
    public static func showHUD(message: String) {
        showToast(message: message)
    }

    /// Show HUD with detail message
    public static func showHUDWithDetail(message: String) {
        showToast(message: message)
    }

    /// Show loading HUD
    public static func showHUDLoading() {
        // Implement loading indicator
        print("Loading...")
    }

    /// Hide loading HUD
    public static func hideHUDLoading() {
        // Implement loading indicator dismissal
        print("Loading complete")
    }

    // MARK: - Screen Size

    /// Get fixed screen size
    public static func fixedScreenSize() -> CGSize {
        return UIScreen.main.bounds.size
    }

    // MARK: - File System

    /// Create directory if not exists
    public static func createIfNotExists(directory dirName: String) -> String {
        let fileManager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = (documentsPath as NSString).appendingPathComponent(dirName)

        var isDir: ObjCBool = false
        let exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)

        if !exists || !isDir.boolValue {
            try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        }

        return path
    }

    /// Set iCloud backup attribute
    public static func iCloudBackup(path: String, skip: Bool) {
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: path) else { return }

        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = skip

        var urlCopy = url
        try? urlCopy.setResourceValues(resourceValues)
    }

    /// Get iCloud document URL
    public static func iCloudDocumentURL() -> URL? {
        guard let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.wodedata.iCloud-MyInputMethod") else {
            return nil
        }
        return iCloudURL.appendingPathComponent("Documents")
    }

    /// Check if purchased
    public static func checkIsPurchase() -> Bool {
        if !LWPurchaseHelper.isPurchased() {
            let message = NSLocalizedString("Purchase remove all limits", tableName: "Local", bundle: LWPurchaseBundleHelper.getBundle(for: self), comment: "")
            showHUD(message: message)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let url = URL(string: "LWInputMethod://inapp.appin_purchase") {
                    UIApplication.shared.open(url)
                }
            }
            return false
        }
        return true
    }
}
