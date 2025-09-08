//
//  ContentView.swift
//  HyperPaymentDemo
//
//  Created by Eslam on 08/09/2025.
//

import SwiftUI
import OPPWAMobile
import UIKit

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
            if let provider = viewModel.makeCheckoutProvider(checkoutID: item.checkoutId) {
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
