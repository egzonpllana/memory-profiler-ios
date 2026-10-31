//
//  LeakExemptionPolicy.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Decides whether an object is excluded from leak detection.
enum LeakExemptionPolicy {

    /// Whether `object` conforms to `LeakDetectionExempt` or its type is in the ignore list.
    static func isExempt(_ object: AnyObject, typeName: String, filter: LeakDetectionFilter) -> Bool {
        object is LeakDetectionExempt || filter.ignoredTypeNames.contains(typeName)
    }
}
