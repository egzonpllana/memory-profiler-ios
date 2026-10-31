//
//  PaymentFlow.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Child flow whose delegate is declared strong by mistake: coordinator -> flow -> coordinator.
@MainActor
final class PaymentFlow {

    var delegate: CheckoutCoordinator?
}
