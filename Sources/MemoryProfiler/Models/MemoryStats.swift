//
//  MemoryStats.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.7.25.
//

import Foundation

/// Memory usage statistics for the current app process.
///
/// This struct provides comprehensive memory information including
/// used memory, available memory, total device memory, and usage percentages.
/// All values are in bytes and represent real-time system data.
public struct MemoryStats: Sendable {

    /// Memory currently used by the app process (resident size)
    public let usedMemory: UInt64

    /// Memory available to the app process
    public let availableMemory: UInt64

    /// Total physical memory on the device
    public let totalMemory: UInt64

    /// Percentage of total memory currently used
    public let memoryUsagePercentage: Double

    /// Highest memory usage recorded since monitoring started
    public let peakMemoryUsage: UInt64

    /// Timestamp when these statistics were collected
    public let timestamp: Date

    /// Creates memory statistics from raw memory values.
    ///
    /// - Parameters:
    ///   - usedMemory: Memory currently used by the app
    ///   - availableMemory: Memory available to the app
    ///   - totalMemory: Total device memory
    ///   - peakMemoryUsage: Highest memory usage recorded
    public init(usedMemory: UInt64, availableMemory: UInt64, totalMemory: UInt64, peakMemoryUsage: UInt64) {
        self.usedMemory = usedMemory
        self.availableMemory = availableMemory
        self.totalMemory = totalMemory
        self.peakMemoryUsage = peakMemoryUsage
        self.memoryUsagePercentage = totalMemory > 0 ? Double(usedMemory) / Double(totalMemory) * 100.0 : 0
        self.timestamp = Date()
    }
} 
