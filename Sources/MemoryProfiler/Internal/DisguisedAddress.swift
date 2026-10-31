//
//  DisguisedAddress.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A bit-inverted object address used for internal bookkeeping.
///
/// Storing `~address` instead of the address keeps the profiler's own data structures
/// from being reported as referrers when the heap is scanned for pointers to a leaked object.
/// This mirrors the `DisguisedPtr` technique used by the Objective-C runtime.
struct DisguisedAddress: Hashable, Sendable {

    // MARK: - Properties

    let rawValue: UInt

    /// The real address.
    var address: UInt { ~rawValue }

    // MARK: - Initialization

    init(address: UInt) {
        rawValue = ~address
    }
}
