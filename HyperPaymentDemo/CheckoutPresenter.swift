//
//  CheckoutPresenter.swift
//  HyperPaymentDemo
//
//  Created by Eslam Abotaleb on 08/09/2025.
//

import UIKit
import SwiftUI

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
