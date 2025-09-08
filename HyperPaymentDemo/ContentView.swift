//
//  ContentView.swift
//  HyperPaymentDemo
//
//  Created by Eslam on 08/09/2025.
//

import SwiftUI
import OPPWAMobile
import UIKit
//        "id": "957BD0FA5BC53A4B07FD1CA340A28F58.uat01-vm-tx02",

struct ContentView: View {
    @StateObject private var viewModel = CheckoutViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.resultText).padding()

            Button("Start payment") {
                viewModel.startPayment()
            }
        }
        .sheet(item: $viewModel.checkoutItem) { item in
            if let provider = viewModel.makeCheckoutProvider(checkoutID: "957BD0FA5BC53A4B07FD1CA340A28F58.uat01-vm-tx02") {
                CheckoutPresenter(checkoutProvider: provider) { transaction in
                    viewModel.checkoutItem = nil
                    viewModel.handleTransaction(transaction)
                }
            } else {
                Text("Failed to create checkout provider")
            }
        }
    }
}

