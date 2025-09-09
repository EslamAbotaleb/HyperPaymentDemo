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
    @State private var showPaymentMethods = false

    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.resultText).padding()

            Button("Start payment") {
                showPaymentMethods = true
            }
        }
        .sheet(isPresented: $showPaymentMethods) {
            PaymentMethodSelectionView(
                isPresented: $showPaymentMethods, viewModel: viewModel 
            )
        }
    }
}
