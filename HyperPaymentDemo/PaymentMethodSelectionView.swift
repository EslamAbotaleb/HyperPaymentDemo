//
//  PaymentMethodSelectionView.swift
//  HyperPaymentDemo
//
//  Created by Eslam Abotaleb on 08/09/2025.
//

import SwiftUI

struct PaymentMethodSelectionView: View {
    @State private var selectedMethod: String? = nil
    @State private var showPaymentDetails = false
    @Binding var isPresented: Bool // <-- control dismissal

    let availableBalance: Double = 4707.00
    @ObservedObject var viewModel: CheckoutViewModel
    @State private var showCheckout = false
    @State private var checkoutProvider: OPPCheckoutProvider? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                
                Text("Choose your preferred payment method")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Credit/Debit Cards")
                        .font(.headline)
                    
                    PaymentMethodRow(iconColor: .blue, title: "Visa", subtitle: "Visa cards accepted", selected: selectedMethod == "VISA") {
                        selectedMethod = "VISA"
                        self.viewModel.startPayment()
                    }
                    
                    PaymentMethodRow(iconColor: .orange, title: "Mastercard", subtitle: "Mastercard accepted", selected: selectedMethod == "MASTER") {
                        selectedMethod = "MASTER"
                        self.viewModel.startPayment()
                    }
                    
                    PaymentMethodRow(iconColor: .green, title: "Mada", subtitle: "Mada cards accepted", selected: selectedMethod == "MADA") {
                        selectedMethod = "MADA"
                        self.viewModel.startPayment()
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Digital Wallets")
                        .font(.headline)
                    
                    PaymentMethodRow(iconColor: .red, title: "Wallet", subtitle: "Use your wallet balance\n$\(String(format: "%.2f", availableBalance)) Available Balance", selected: selectedMethod == "WALLET") {
                        selectedMethod = "WALLET"
                    }
                }
                
                Spacer()

                Button("Continue") {
                    if let provider = viewModel.makeCheckoutProvider(checkoutID: viewModel.checkoutItem?.checkoutId ?? "", selectedMethod: selectedMethod ?? "VISA") {
                        checkoutProvider = provider
                        showCheckout = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedMethod != nil ? Color.red : Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(10)
                .fullScreenCover(isPresented: $showCheckout) {
                    if let provider = checkoutProvider {
                        CheckoutPresenterView(checkoutProvider: provider,
                                              completion: { transaction in
                                                  viewModel.checkoutItem = nil        // <-- reset here
                                                  viewModel.handleTransaction(transaction)
                                                  isPresented = false                // dismiss selection view
                                              },
                                              isPresented: $showCheckout)
                    }
                }
                .disabled(selectedMethod == nil)
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("Payment Method")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}




struct PaymentMethodRow: View {
    var iconColor: Color
    var title: String
    var subtitle: String
    var selected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(iconColor.opacity(0.3))
                    .frame(width: 40, height: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(iconColor, lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .bold()
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
    }
}
