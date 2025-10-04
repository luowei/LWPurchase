//
// ExampleApp.swift
// LWPurchase
//
// Example application demonstrating LWPurchase usage
// This file shows various integration patterns
//

import SwiftUI
import LWPurchase

// MARK: - SwiftUI App Example (iOS 14+)

@available(iOS 14.0, *)
@main
struct PurchaseExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Main Content View

@available(iOS 14.0, *)
struct ContentView: View {
    @StateObject private var purchaseManager = LWPurchaseManager.shared
    @State private var showPurchaseSheet = false
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Basic Integration
            BasicExampleView()
                .tabItem {
                    Label("Basic", systemImage: "1.circle")
                }
                .tag(0)

            // Tab 2: Modern View
            ModernExampleView()
                .tabItem {
                    Label("Modern", systemImage: "2.circle")
                }
                .tag(1)

            // Tab 3: Advanced
            AdvancedExampleView()
                .tabItem {
                    Label("Advanced", systemImage: "3.circle")
                }
                .tag(2)
        }
    }
}

// MARK: - Basic Example View

@available(iOS 14.0, *)
struct BasicExampleView: View {
    @State private var showPurchase = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)

                Text("Basic Integration")
                    .font(.title)
                    .fontWeight(.bold)

                // Purchase Status
                HStack {
                    Text("Purchase Status:")
                    Text(LWPurchase.shared.isPurchased ? "✓ Purchased" : "✗ Not Purchased")
                        .foregroundColor(LWPurchase.shared.isPurchased ? .green : .red)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)

                // Actions
                VStack(spacing: 12) {
                    Button("Show Purchase View") {
                        showPurchase = true
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Check Purchase Status") {
                        print("Is Purchased: \(LWPurchase.shared.isPurchased)")
                        print("Need Purchase: \(LWPurchase.shared.isNeedPurchase)")
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Request Review") {
                        LWPurchase.shared.showRating()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding()

                Spacer()
            }
            .padding()
            .navigationTitle("Basic Example")
            .sheet(isPresented: $showPurchase) {
                LWPurchase.shared.purchaseView()
            }
        }
    }
}

// MARK: - Modern Example View

@available(iOS 14.0, *)
struct ModernExampleView: View {
    @State private var showPurchase = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Modern UI")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Enhanced purchase experience with modern SwiftUI design")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                Button("Show Modern Purchase UI") {
                    showPurchase = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()

                Spacer()
            }
            .padding()
            .navigationTitle("Modern Example")
            .sheet(isPresented: $showPurchase) {
                ModernPurchaseView()
            }
        }
    }
}

// MARK: - Advanced Example View

@available(iOS 14.0, *)
struct AdvancedExampleView: View {
    @StateObject private var viewModel = PurchaseViewModel()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Status")) {
                    HStack {
                        Text("Purchased")
                        Spacer()
                        Text(viewModel.isPurchased ? "Yes" : "No")
                            .foregroundColor(viewModel.isPurchased ? .green : .red)
                    }

                    HStack {
                        Text("Loading")
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("No")
                                .foregroundColor(.secondary)
                        }
                    }

                    if let error = viewModel.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                    }
                }

                Section(header: Text("Products")) {
                    if viewModel.products.isEmpty {
                        Text("No products loaded")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.products, id: \.productIdentifier) { product in
                            VStack(alignment: .leading) {
                                Text(product.localizedTitle)
                                    .font(.headline)
                                Text(product.localizedDescription)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section(header: Text("Actions")) {
                    Button("Fetch Products") {
                        viewModel.fetchProducts()
                    }

                    Button("Purchase First Product") {
                        viewModel.purchaseFirstProduct()
                    }
                    .disabled(viewModel.products.isEmpty)

                    Button("Restore Purchases") {
                        viewModel.restorePurchases()
                    }

                    Button("Reload Configuration") {
                        viewModel.reloadConfig()
                    }
                }

                Section(header: Text("Async Example (iOS 15+)")) {
                    if #available(iOS 15.0, *) {
                        Button("Fetch & Purchase (Async)") {
                            Task {
                                await viewModel.fetchAndPurchaseAsync()
                            }
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
            }
            .navigationTitle("Advanced Example")
        }
    }
}

// MARK: - View Model

@available(iOS 13.0, *)
class PurchaseViewModel: ObservableObject {
    @Published var isPurchased = false
    @Published var isLoading = false
    @Published var products: [SKProduct] = []
    @Published var errorMessage: String?

    private let manager = LWPurchaseManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Bind to manager's published properties
        manager.$isPurchased
            .assign(to: &$isPurchased)

        manager.$isLoading
            .assign(to: &$isLoading)

        manager.$products
            .assign(to: &$products)

        manager.$errorMessage
            .assign(to: &$errorMessage)
    }

    func fetchProducts() {
        manager.fetchProducts()
    }

    func purchaseFirstProduct() {
        guard let product = products.first else { return }
        manager.purchase(product)
    }

    func restorePurchases() {
        manager.restorePurchases()
    }

    func reloadConfig() {
        manager.reloadConfiguration()
    }

    @available(iOS 15.0, *)
    func fetchAndPurchaseAsync() async {
        do {
            let products = try await LWPurchase.shared.fetchProducts()
            guard let product = products.first else {
                errorMessage = "No products available"
                return
            }

            try await LWPurchase.shared.purchase(product)
            print("Purchase completed successfully!")
        } catch {
            errorMessage = error.localizedDescription
            print("Error: \(error)")
        }
    }
}

// MARK: - Custom Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - UIKit Integration Example

import UIKit

@available(iOS 13.0, *)
class UIKitExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "UIKit Example"

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Purchase button
        let purchaseButton = UIButton(type: .system)
        purchaseButton.setTitle("Show Purchase View", for: .normal)
        purchaseButton.addTarget(self, action: #selector(showPurchaseView), for: .touchUpInside)
        styleButton(purchaseButton)

        // Status label
        let statusLabel = UILabel()
        statusLabel.text = "Purchase Status: \(LWPurchase.shared.isPurchased ? "✓ Purchased" : "✗ Not Purchased")"
        statusLabel.textAlignment = .center

        stackView.addArrangedSubview(purchaseButton)
        stackView.addArrangedSubview(statusLabel)

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    @objc private func showPurchaseView() {
        if let navController = LWPurchase.shared.navigationController() {
            present(navController, animated: true)
        }
    }

    private func styleButton(_ button: UIButton) {
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
    }
}

// MARK: - Callback-based Example

class CallbackExample {

    func purchaseExample() {
        // Check if can make payments
        guard LWPurchase.shared.canMakePayments else {
            print("Cannot make payments on this device")
            return
        }

        // Fetch products
        LWPurchase.shared.fetchProducts { products in
            guard let product = products.first else {
                print("No products available")
                return
            }

            print("Found product: \(product.localizedTitle)")

            // Purchase the product
            LWPurchase.shared.purchase(product)
        }
    }

    func restoreExample() {
        LWPurchase.shared.restorePurchases()
    }

    func checkStatusExample() {
        if LWPurchase.shared.isPurchased {
            print("User has purchased")
        } else if LWPurchase.shared.isNeedPurchase {
            print("Purchase is needed")
        }
    }
}

// MARK: - Preview

@available(iOS 14.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
