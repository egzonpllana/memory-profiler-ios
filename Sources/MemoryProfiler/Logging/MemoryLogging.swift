//
//  MemoryLogging.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

/// Handles formatted output of memory profiling information.
///
/// Implementations control where and how profiler messages are emitted
/// (console, OSLog, custom sinks, etc.).
public protocol MemoryLogging {

    /// Logs an informational message.
    ///
    /// - Parameter message: The message to emit.
    func log(_ message: String)

    /// Logs a warning-level message.
    ///
    /// - Parameter message: The warning to emit.
    func logWarning(_ message: String)
}
