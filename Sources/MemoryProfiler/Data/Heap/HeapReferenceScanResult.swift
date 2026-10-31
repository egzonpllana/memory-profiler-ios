//
//  HeapReferenceScanResult.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Output of one heap walk for referrers.
struct HeapReferenceScanResult {

    /// Pointers found, in heap order.
    let hits: [HeapReferenceHit]

    /// Swift weak reference side tables of the targets; pointers from them are not ownership.
    let sideTables: Set<DisguisedAddress>

    /// Whether the hit buffer filled up.
    let isTruncated: Bool
}
