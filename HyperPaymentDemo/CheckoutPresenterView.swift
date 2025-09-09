//
//  CheckoutPresenterView.swift
//  HyperPaymentDemo
//
//  Created by Eslam Abotaleb on 09/09/2025.
//

import UIKit
import SwiftUI

struct CheckoutPresenterView: UIViewControllerRepresentable {
    let checkoutProvider: OPPCheckoutProvider
    let completion: (OPPTransaction?) -> Void
    @Binding var isPresented: Bool  // <-- binding to control presentation

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController() // container VC
        DispatchQueue.main.async {
            checkoutProvider.presentCheckout(
                forSubmittingTransactionCompletionHandler: { transaction, error in
                    DispatchQueue.main.async {
                        completion(transaction)
                        isPresented = false // dismiss fullScreenCover
                    }
                },
                cancelHandler: {
                    DispatchQueue.main.async {
                        print("User canceled the payment.")
                        isPresented = false // dismiss fullScreenCover
                    }
                }
            )
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
