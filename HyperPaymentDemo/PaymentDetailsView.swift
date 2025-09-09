//
//  PaymentDetailsView.swift
//  HyperPaymentDemo
//
//  Created by Eslam Abotaleb on 08/09/2025.
//

import SwiftUI
import UIKit
//
//struct PaymentDetailsView: View {
//    let checkoutId: String
//    @ObservedObject var viewModel: CheckoutViewModel
//    let brand: String
//
//    @State private var cardNumber = ""
//    @State private var cardHolder = ""
//    @State private var expiryMonth = ""
//    @State private var expiryYear = ""
//    @State private var cvv = ""
//    @State private var isProcessing = false
//    @State private var errorMessage: String?
//    @State private var isCVVHidden = true
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            TextField("Card Number", text: $cardNumber)
//                .keyboardType(.numberPad)
//                .textFieldStyle(.roundedBorder)
//            
//            TextField("Name on Card", text: $cardHolder)
//                .textFieldStyle(.roundedBorder)
//            
//            HStack {
//                TextField("MM", text: $expiryMonth)
//                    .keyboardType(.numberPad)
//                    .textFieldStyle(.roundedBorder)
//                TextField("YY", text: $expiryYear)
//                    .keyboardType(.numberPad)
//                    .textFieldStyle(.roundedBorder)
//               
//                HStack {
//                    ZStack {
//                        if isCVVHidden {
//                            SecureField("CVV", text: $cvv)
//                                .keyboardType(.numberPad)
//                                .padding(.trailing, 40) // space for eye button
//                        } else {
//                            TextField("CVV", text: $cvv)
//                                .keyboardType(.numberPad)
//                                .padding(.trailing, 40)
//                        }
//                    }
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(10)
//                    .overlay(
//                        Button(action: { isCVVHidden.toggle() }) {
//                            Image(systemName: isCVVHidden ? "eye.slash" : "eye")
//                                .foregroundColor(.gray)
//                        }
//                        .padding(.trailing, 8),
//                        alignment: .trailing
//                    )
//                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
//                }
//                .frame(height: 50)
//            }
//
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//            }
//            
//            Button(action: startHyperPayCheckout) {
//                if isProcessing {
//                    ProgressView()
//                        .progressViewStyle(.circular)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.gray)
//                        .cornerRadius(10)
//                } else {
//                    Text("Pay")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.red)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//            }
//            .disabled(isProcessing)
//            
//            Spacer()
//        }
//        .padding()
//        .navigationTitle("Payment Details")
//    }
//
//    func startHyperPayCheckout() {
//        isProcessing = true
//        errorMessage = nil
//        
//        guard let checkoutProvider = viewModel.makeCheckoutProvider(checkoutID: checkoutId) else {
//            errorMessage = "Failed to create checkout"
//            isProcessing = false
//            return
//        }
//        
//        // HyperPay SDK call
//        checkoutProvider.presentCheckout(
//            withPaymentBrand: brand,
//            loadingHandler: { inProgress in
//                isProcessing = inProgress
//            },
//            completionHandler: { transaction, error in
//                isProcessing = false
//                if let t = transaction {
//                    viewModel.handleTransaction(t)
//                } else {
//                    errorMessage = error?.localizedDescription ?? "Payment failed"
//                }
//            },
//            cancelHandler: {
//                isProcessing = false
//                errorMessage = "Payment cancelled"
//            }
//        )
//    }
//}

