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
        settings.paymentBrands = Config.checkoutPaymentBrands
        settings.shopperResultURL = "your-app-scheme://result"

        // If we want Apple Pay to appear, configure a PKPaymentRequest and attach it.
        if Config.checkoutPaymentBrands.contains("APPLEPAY") {
            // quick runtime check: device & wallet availability
            if PKPaymentAuthorizationController.canMakePayments() {
                let paymentRequest = PKPaymentRequest()
                paymentRequest.merchantIdentifier = "merchant.com.yourcompany.app" // <<-- replace with your merchant id
                paymentRequest.countryCode = "US"               // set appropriate country code for your merchant
                paymentRequest.currencyCode = Config.currency  // e.g. "USD" or "SAR"
                // choose supported networks that your merchant accepts
                paymentRequest.supportedNetworks = [
                    .visa,
                    .masterCard,
                    .amex,
                    .discover,
                    .maestro,
                    .mada           // available in modern iOS versions
                ].compactMap { $0 } // keeps code safe if any network isn't available on older SDKs

                // set merchant capabilities (3DS usually required)
                paymentRequest.merchantCapabilities = .threeDSecure

                // item shown in Apple Pay sheet (label + amount)
                paymentRequest.paymentSummaryItems = [
                    PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(value: Config.amount))
                ]

                // assign to the SDK settings (this is the correct place to configure Apple Pay for OPP)
                settings.applePayPaymentRequest = paymentRequest

                // optionally choose the Apple Pay button style shown in the checkout
                settings.applePayType = .plain // or .plain / .setUp / .donate etc.
            } else {
                print("Apple Pay not available on this device or no cards added in Wallet")
            }
        }

        return OPPCheckoutProvider(paymentProvider: paymentProvider, checkoutID: checkoutID, settings: settings)
    }
    
// MARK: - Old Implment For Function makeCheckoutProvider
  /*
   func makeCheckoutProvider(checkoutID: String) -> OPPCheckoutProvider? {
       let paymentProvider = OPPPaymentProvider(mode: .test) // .test or .live
//        let settings = OPPCheckoutSettings()
//        settings.paymentBrands = Config.checkoutPaymentBrands
       let settings = OPPCheckoutSettings()
       settings.paymentBrands = Config.checkoutPaymentBrands
       // General colors of the checkout UI
       settings.theme.primaryBackgroundColor = UIColor.white
       settings.theme.primaryForegroundColor = UIColor.black
       settings.theme.confirmationButtonColor = UIColor.orange
       settings.theme.confirmationButtonTextColor = UIColor.white
       settings.theme.errorColor = UIColor.red
       
//        settings.theme.activityIndicatorStyle = .gray;
       settings.theme.separatorColor = UIColor.lightGray

       // Navigation bar customization
       settings.theme.navigationBarTintColor = UIColor.white
       settings.theme.navigationBarBackgroundColor = UIColor.orange
       settings.theme.navigationBarTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
       settings.theme.navigationItemTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
       settings.theme.cancelBarButtonImage = UIImage(named: "shopping_cart_black_icon")

       // Payment brands list customization
       settings.theme.cellHighlightedBackgroundColor = UIColor.orange
       settings.theme.cellHighlightedTextColor = UIColor.white

       // Fonts customization
       settings.theme.primaryFont = UIFont.systemFont(ofSize: 14.0)
       settings.theme.secondaryFont = UIFont.systemFont(ofSize: 12.0)
       settings.theme.confirmationButtonFont = UIFont.systemFont(ofSize: 15.0)
       settings.theme.errorFont = UIFont.systemFont(ofSize: 12.0)
       settings.shopperResultURL = "your-app-scheme://result"
       return OPPCheckoutProvider(paymentProvider: paymentProvider, checkoutID: checkoutID, settings: settings)
   }
   
   */
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
            resultText = "Async transaction — redirect URL: \(t.redirectURL?.absoluteString ?? "nil")"
        }
    }
}
