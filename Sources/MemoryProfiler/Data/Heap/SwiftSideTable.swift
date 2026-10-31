//
//  SwiftSideTable.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Decodes the side table address from a native Swift object's inline reference count.
///
/// When a native Swift object is weakly referenced, its reference count word holds
/// `UseSlowRC | SideTableMark | (sideTable >> 3)`. The side table points back to the object,
/// so it must be excluded from referrer results.
enum SwiftSideTable {

    // MARK: - Properties

    private static let markerBits: UInt = 0b11 << 62
    private static let pointerMask: UInt = (1 << 62) - 1
    private static let unusedLowBits: UInt = 3

    // MARK: - Public Methods

    /// The side table address, or `nil` when the word does not encode one.
    static func address(fromReferenceCountWord word: UInt) -> UInt? {
        guard word & markerBits == markerBits else { return nil }
        let address = (word & pointerMask) << unusedLowBits
        return address == 0 ? nil : address
    }
}
