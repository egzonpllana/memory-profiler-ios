//
//  ExpectationDraft.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Everything known about an expectation before the store assigns its token.
struct ExpectationDraft {

    // MARK: - Properties

    let address: DisguisedAddress
    let descriptor: ObjectDescriptor
    let request: DeallocationRequest
    let context: DeallocationExpectationContext

    // MARK: - Public Methods

    /// The pending expectation for `object`.
    ///
    /// A weak reference is formed only for actors, which cannot carry a sentinel, and for usage
    /// probes, which only automatic UIKit tracking requests for live objects. Forming a weak
    /// reference to an Objective-C object that is deallocating aborts the process.
    func expectation(token: UInt64, object: AnyObject, isObservable: Bool) -> DeallocationExpectation {
        DeallocationExpectation(
            token: token,
            liveness: isObservable ? .observedBySentinel : .weakReference(WeakObjectBox(object)),
            probeTarget: request.usageProbe == nil ? nil : WeakObjectBox(object),
            address: address,
            descriptor: descriptor,
            request: request,
            context: context,
            phase: .pending
        )
    }
}
