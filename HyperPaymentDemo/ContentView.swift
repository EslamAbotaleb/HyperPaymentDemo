//
//  ContentView.swift
//  HyperPaymentDemo
//
//  Created by Eslam on 08/09/2025.
//

import SwiftUI
import OPPWAMobile
import UIKit

//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//    }
//}

//#Preview {
//    ContentView()
//}
//
//// Helper to create provider
//func makeCheckoutProvider(checkoutID: String) -> OPPCheckoutProvider? {
//    let paymentProvider = OPPPaymentProvider(mode: .test) // or .live
//    let settings = OPPCheckoutSettings()
//    // configure brands you want to show, e.g. ["VISA", "MASTER", "MADA"] if available
//    settings.paymentBrands = ["VISA", "MASTER", "MADA"]
//    // optional: settings.shopperResultURL = "your-app-scheme://result"
//    return OPPCheckoutProvider(paymentProvider: paymentProvider, checkoutID: checkoutID, settings: settings)
//}
//
//// UIViewController wrapper that calls presentCheckout once
//struct CheckoutPresenter: UIViewControllerRepresentable {
//    let checkoutProvider: OPPCheckoutProvider
//    let onComplete: (OPPTransaction?) -> Void
//
//    func makeCoordinator() -> Coordinator { Coordinator() }
//
//    func makeUIViewController(context: Context) -> UIViewController {
//        // simple host VC — SDK will present modally from this
//        let vc = UIViewController()
//        vc.view.backgroundColor = .clear
//        return vc
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        // present only once
//        guard !context.coordinator.didPresent else { return }
//        context.coordinator.didPresent = true
//
//        DispatchQueue.main.async {
//            self.checkoutProvider.presentCheckout(forSubmittingTransactionCompletionHandler: { transaction, error in
//                // transaction == nil => error or failed
//                if let transaction = transaction {
//                    // synchronous vs asynchronous handling:
//                    if transaction.type == .synchronous {
//                        // synchronously completed in-app — ask your backend for final status
//                        // use transaction.resourcePath or your checkoutID
//                        print("Synchronous transaction; resourcePath:", transaction.resourcePath ?? "nil")
//                    } else {
//                        // asynchronous — SDK may have opened redirect/issuer flow
//                        print("Asynchronous transaction; redirect URL:", transaction.redirectURL?.absoluteString ?? "nil")
//                    }
//                } else {
//                    print("Transaction nil, error:", error?.localizedDescription ?? "unknown")
//                }
//
//                // dismiss the modal UI presented by SDK (SDK may already dismiss, but safe to call)
//                uiViewController.dismiss(animated: true) {
//                    self.onComplete(transaction)
//                }
//
//            }, cancelHandler: {
//                // user cancelled
//                uiViewController.dismiss(animated: true) {
//                    self.onComplete(nil)
//                }
//            })
//        }
//    }
//
//    class Coordinator {
//        var didPresent = false
//    }
//}
// Small wrapper to make String Identifiable for SwiftUI sheet
struct CheckoutItem: Identifiable {
    let id = UUID()
    let checkoutId: String
}

// UIViewControllerRepresentable wrapper for OPPCheckoutProvider
struct CheckoutPresenter: UIViewControllerRepresentable {
    let checkoutProvider: OPPCheckoutProvider
    let onComplete: (OPPTransaction?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard !context.coordinator.didPresent else { return }
        context.coordinator.didPresent = true

        DispatchQueue.main.async {
            self.checkoutProvider.presentCheckout(forSubmittingTransactionCompletionHandler: { transaction, error in
                uiViewController.dismiss(animated: true) {
                    self.onComplete(transaction)
                }
            }, cancelHandler: {
                uiViewController.dismiss(animated: true) {
                    self.onComplete(nil)
                }
            })
        }
    }

    class Coordinator {
        var didPresent = false
    }
}

// Function to create checkout provider
func makeCheckoutProvider(checkoutID: String) -> OPPCheckoutProvider? {
    let paymentProvider = OPPPaymentProvider(mode: .test) // .test or .live
    let settings = OPPCheckoutSettings()
    settings.paymentBrands = ["VISA", "MASTER", "MADA"]
    settings.shopperResultURL = "your-app-scheme://result" // optional
    return OPPCheckoutProvider(paymentProvider: paymentProvider, checkoutID: checkoutID, settings: settings)
}

// SwiftUI ContentView
//struct ContentView: View {
//    @State private var checkoutItem: CheckoutItem? = nil
//    @State private var resultText = "No payment yet"
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text(resultText).padding()
//
//            Button("Start payment") {
//                // Request checkout ID from backend / test server
//                Request.requestCheckoutID(amount: Config.amount, currency: Config.currency) { checkoutID in
//                    DispatchQueue.main.async {
//                        if let checkoutID = checkoutID {
//                            print("✅ Got checkout ID:", checkoutID)
//                            self.checkoutItem = CheckoutItem(checkoutId: checkoutID)
//                        } else {
//                            self.resultText = "Failed to get checkout ID"
//                        }
//                    }
//                }
//            }
//        }
//        .sheet(item: $checkoutItem) { item in
//            if let provider = makeCheckoutProvider(checkoutID: item.checkoutId) {
//                CheckoutPresenter(checkoutProvider: provider) { transaction in
//                    checkoutItem = nil
//                    if let t = transaction {
//                        if t.type == .synchronous {
//                            resultText = "Sync finished — resourcePath: \(t.resourcePath ?? "nil")"
//                        } else {
//                            resultText = "Async — redirect: \(t.redirectURL?.absoluteString ?? "nil")"
//                        }
//                    } else {
//                        resultText = "Payment cancelled or failed."
//                    }
//                }
//            } else {
//                Text("Failed to create checkout provider")
//            }
//        }
//    }
//}
struct ContentView: View {
    @State private var checkoutItem: CheckoutItem? = nil
    @State private var resultText = "No payment yet"

    var body: some View {
        VStack(spacing: 20) {
            Text(resultText).padding()

            Button("Start payment") {
                Request.requestCheckoutID(amount: Config.amount, currency: Config.currency) { checkoutID in
                    DispatchQueue.main.async {
                        if let checkoutID = checkoutID {
                            print("✅ Got checkout ID:", checkoutID)
                            self.checkoutItem = CheckoutItem(checkoutId: checkoutID)
                        } else {
                            self.resultText = "Failed to get checkout ID"
                        }
                    }
                }
            }
        }
        .sheet(item: $checkoutItem) { item in
            if let provider = makeCheckoutProvider(checkoutID: item.checkoutId) {
                CheckoutPresenter(checkoutProvider: provider) { transaction in
                    checkoutItem = nil

                    guard let t = transaction else {
                        resultText = "Payment cancelled or failed."
                        return
                    }

                    if t.type == .synchronous {
                        // synchronous transaction finished in-app — now request final status from backend
                        Request.requestPaymentStatus(resourcePath: t.resourcePath ?? "") { statusResponse, error in
                            DispatchQueue.main.async {
                                if let status = statusResponse {
                                    resultText = "Payment status: \(status.resultCode ?? "unknown") — \(status.resultDescription ?? "")"
                                    print(resultText)
                                } else {
                                    resultText = "Failed to get payment status: \(error?.localizedDescription ?? "unknown error")"
                                }
                            }
                        }
                    } else {
                        // asynchronous transaction (redirect flow)
                        resultText = "Async transaction — redirect URL: \(t.redirectURL?.absoluteString ?? "nil")"
                    }
                }
            } else {
                Text("Failed to create checkout provider")
            }
        }
    }
}
