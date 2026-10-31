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
    let liveness: ExpectationLiveness
    /// Weak reference used only by usage probes, for objects that are alive when tracked (UIKit).
    let probeTarget: WeakObjectBox?
    let address: DisguisedAddress
    let descriptor: ObjectDescriptor
    let request: DeallocationRequest
    let context: DeallocationExpectationContext
    var phase: ExpectationPhase

    /// Heap addresses of the weak boxes owned by this expectation.
    var boxAddresses: [UInt] {
        [liveness.box, probeTarget].compactMap { $0?.address }
    }

    /// Whether a usage probe says the object went back into legitimate use, or the probed object is gone.
    /// Loads a weak reference; call on the main thread.
    var isBackInUse: Bool {
        guard let probe = request.usageProbe else { return false }
        guard let target = probeTarget?.object else { return true }
        return probe.isObjectInUse(target)
    }

    /// The report published if the object is still alive at the deadline.
    func makeReport(detectedAt: Date) -> LeakReport {
        LeakReport(object: descriptor, expectation: context, detectedAt: detectedAt)
    }
}
