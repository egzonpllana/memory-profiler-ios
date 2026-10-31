//
//  LeakAlertPolicy.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// What happens, in addition to logging, when a leak is detected.
public enum LeakAlertPolicy: Sendable, Equatable {

    /// Log the leak only.
    case log

    /// Log the leak and call `assertionFailure`, which stops debug builds.
    case assertionFailure

    /// Log the leak and pause in the debugger when one is attached, so the
    /// Debug Memory Graph can be opened while the leaked object is still alive.
    case breakpoint
}
