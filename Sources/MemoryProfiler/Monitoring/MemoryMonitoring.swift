//
//  MemoryMonitoring.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

/// Reads memory statistics from the operating system.
///
/// Implementations wrap platform-specific APIs to provide
/// a testable abstraction over system memory queries.
public protocol MemoryMonitoring: Sendable {

    /// Returns the current memory usage of the app process in bytes.
    func currentMemoryUsage() -> UInt64

    /// Returns the total physical memory on the device in bytes.
    func totalMemory() -> UInt64
}
