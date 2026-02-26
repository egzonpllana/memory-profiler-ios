//
//  DebugLog.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

/// Debug-only logging utility for internal MemoryProfiler diagnostics.
///
/// All output is suppressed in release builds via compile-time `#if DEBUG`.
enum DebugLog {

    /// Prints a message only in DEBUG builds.
    ///
    /// - Parameter message: The diagnostic message to print.
    static func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
}
