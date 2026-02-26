//
//  ConsoleMemoryLogger.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

/// Emits memory profiler messages to the console via `print`.
///
/// Messages are prefixed with `[MemoryProfiler]` for easy filtering.
/// Output is suppressed in release builds.
public struct ConsoleMemoryLogger: MemoryLogging {

    // MARK: - Initialization

    /// Creates a console memory logger.
    public init() {}

    // MARK: - MemoryLogging

    public func log(_ message: String) {
        #if DEBUG
        print("[MemoryProfiler] \(message)")
        #endif
    }

    public func logWarning(_ message: String) {
        #if DEBUG
        print("[MemoryProfiler] WARNING: \(message)")
        #endif
    }
}
