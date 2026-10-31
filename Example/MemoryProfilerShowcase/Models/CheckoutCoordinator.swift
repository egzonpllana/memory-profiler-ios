//
//  CheckoutCoordinator.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Owns the payment flow and is its delegate.
@MainActor
final class CheckoutCoordinator {

    private var paymentFlow: PaymentFlow?

    func startPayment() {
        let flow = PaymentFlow()
        flow.delegate = self
        paymentFlow = flow
    }
}
