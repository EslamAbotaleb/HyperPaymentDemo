//
//  CheckoutViewModel.swift
//  HyperPaymentDemo
//
//  Created by Eslam Abotaleb on 08/09/2025.
//


import Foundation
import OPPWAMobile

class CheckoutViewModel: ObservableObject {
    @Published var resultText: String = "No payment yet"
    @Published var checkoutItem: CheckoutItem? = nil
    @Published var checkoutProvider: OPPCheckoutProvider? = nil
    
    func makeCheckoutProvider(checkoutID: String, selectedMethod: String) -> OPPCheckoutProvider? {
        let paymentProvider = OPPPaymentProvider(mode: .test)
        let settings = OPPCheckoutSettings()
        
        // Only include the selected payment method
        settings.paymentBrands = [selectedMethod]

        settings.shopperResultURL = "your-app-scheme://result"

        // Apple Pay setup (optional)
        if selectedMethod == "APPLEPAY" {
            if PKPaymentAuthorizationController.canMakePayments() {
                let paymentRequest = PKPaymentRequest()
                paymentRequest.merchantIdentifier = "merchant.com.yourcompany.app"
                paymentRequest.countryCode = "US"
                paymentRequest.currencyCode = Config.currency
                paymentRequest.supportedNetworks = [.visa, .masterCard, .mada].compactMap { $0 }
                paymentRequest.merchantCapabilities = .threeDSecure
                paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(value: Config.amount))]
                settings.applePayPaymentRequest = paymentRequest
                settings.applePayType = .plain
            }
        }

        let checkoutProvider = OPPCheckoutProvider(paymentProvider: paymentProvider, checkoutID: checkoutID, settings: settings)
        self.checkoutProvider = checkoutProvider
        return checkoutProvider
    }

    func startPayment() {
        Request.requestCheckoutID(amount: Config.amount, currency: Config.currency) { checkoutID in
            Task {
                @MainActor in
                if let checkoutID = checkoutID {
                    print("✅ Got checkout ID:", checkoutID)
                    self.checkoutItem = CheckoutItem(checkoutId: checkoutID)
                } else {
                    self.resultText = "Failed to get checkout ID"
                }
            }
        }
    }
    
    func handleTransaction(_ transaction: OPPTransaction?) {
        guard let t = transaction else {
            resultText = "Payment cancelled or failed."
            return
        }
        
        if t.type == .synchronous {
            Request.requestPaymentStatus(resourcePath: t.resourcePath ?? "") { statusResponse, error in
                Task {
                    @MainActor in
                    if let status = statusResponse {
                        self.resultText = "Payment status: \(status.resultCode) — \(status.resultDescription)"
                    } else {
                        self.resultText = "Failed to get payment status: \(error?.localizedDescription ?? "unknown error")"
                    }
                }
            }
        } else {
            /// this success  behave but difference type payment 
            resultText = "Async transaction — redirect URL: \(t.redirectURL?.absoluteString ?? "nil")"
            
            print(resultText)
        }
    }
}
