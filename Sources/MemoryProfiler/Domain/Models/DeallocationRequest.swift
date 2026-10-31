//
//  DeallocationRequest.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Parameters of a single deallocation expectation.
struct DeallocationRequest: Sendable {

    /// Grace period override; `nil` uses the configured grace period.
    let gracePeriod: Duration?

    /// Why the object is expected to deallocate.
    let reason: DeallocationExpectationReason

    /// Source position of the expectation.
    let location: SourceLocation

    /// Checks at the deadline whether the object went back into use, such as a re-attached view controller.
    let usageProbe: (any ObjectUsageProbing)?
}
