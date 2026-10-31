//
//  ObjectUsageProbing.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Decides at the deadline whether an object went back into legitimate use.
protocol ObjectUsageProbing: Sendable {

    /// Whether `object` is in use again. Called on the main thread.
    func isObjectInUse(_ object: AnyObject) -> Bool
}
