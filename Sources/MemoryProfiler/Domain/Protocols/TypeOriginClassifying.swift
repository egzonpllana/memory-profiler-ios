//
//  TypeOriginClassifying.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Tells application classes from Apple framework and standard library classes.
protocol TypeOriginClassifying: Sendable {

    /// Whether `type` is defined by an Apple framework or the Swift runtime.
    func isSystemClass(_ type: AnyClass) -> Bool
}
