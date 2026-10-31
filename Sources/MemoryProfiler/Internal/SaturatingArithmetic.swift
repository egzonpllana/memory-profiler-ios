//
//  SaturatingArithmetic.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

extension UInt64 {

    /// `self + other`, clamped to `UInt64.max` instead of trapping on overflow.
    func saturatingAdding(_ other: UInt64) -> UInt64 {
        let result = addingReportingOverflow(other)
        return result.overflow ? .max : result.partialValue
    }

    /// `value` scaled by `fraction` (0...1), clamped to the representable range.
    static func scaled(_ value: UInt64, by fraction: Double) -> UInt64 {
        let product = Double(value) * fraction
        guard product.isFinite, product > 0 else { return 0 }
        return product >= Double(UInt64.max) ? .max : UInt64(product)
    }
}

extension Int {

    /// `self + other`, clamped to the `Int` range instead of trapping on overflow.
    func saturatingAdding(_ other: Int) -> Int {
        let result = addingReportingOverflow(other)
        guard result.overflow else { return result.partialValue }
        return other > 0 ? .max : .min
    }
}
