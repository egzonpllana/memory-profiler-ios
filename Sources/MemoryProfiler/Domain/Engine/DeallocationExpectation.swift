//
//  DeallocationExpectation.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A registered expectation that an object deallocates.
struct DeallocationExpectation: Sendable {

    // MARK: - Properties

    let token: UInt64
    let box: WeakObjectBox
    let address: DisguisedAddress
    let descriptor: ObjectDescriptor
    let request: DeallocationRequest
    let context: DeallocationExpectationContext
    var phase: ExpectationPhase

    /// The report published if the object is still alive at the deadline.
    func makeReport(detectedAt: Date) -> LeakReport {
        LeakReport(object: descriptor, expectation: context, detectedAt: detectedAt)
    }
}
