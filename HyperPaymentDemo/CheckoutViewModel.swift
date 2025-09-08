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
    
    func makeCheckoutProvider(checkoutID: String) -> OPPCheckoutProvider? {
        let paymentProvider = OPPPaymentProvider(mode: .test) // .test or .live
        let settings = OPPCheckoutSettings()
        settings.paymentBrands = ["VISA", "MASTER", "MADA"]
        settings.shopperResultURL = "your-app-scheme://result"
        return OPPCheckoutProvider(paymentProvider: paymentProvider, checkoutID: checkoutID, settings: settings)
    }
    
    func startPayment() {
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
    
    func handleTransaction(_ transaction: OPPTransaction?) {
        guard let t = transaction else {
            resultText = "Payment cancelled or failed."
            return
        }
        
        if t.type == .synchronous {
            Request.requestPaymentStatus(resourcePath: t.resourcePath ?? "") { statusResponse, error in
                DispatchQueue.main.async {
                    if let status = statusResponse {
                        self.resultText = "Payment status: \(status.resultCode) — \(status.resultDescription)"
                    } else {
                        self.resultText = "Failed to get payment status: \(error?.localizedDescription ?? "unknown error")"
                    }
                }
            }
        } else {
            resultText = "Async transaction — redirect URL: \(t.redirectURL?.absoluteString ?? "nil")"
        }
    }
}
