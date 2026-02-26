//
//  SystemMemoryMonitor.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation
import Darwin

/// Reads memory statistics using Darwin `mach_task_basic_info`.
///
/// This is the single location in the SDK that touches kernel APIs.
/// Failures are logged via `DebugLog` and return zero gracefully.
public struct SystemMemoryMonitor: MemoryMonitoring {

    // MARK: - Initialization

    /// Creates a system memory monitor.
    public init() {}

    // MARK: - MemoryMonitoring

    public func currentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(
            MemoryLayout<mach_task_basic_info>.size
        ) / 4

        let result: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }

        if result != KERN_SUCCESS {
            DebugLog.log(
                "[MemoryProfiler] Failed to read memory usage,"
                + " kern_return_t: \(result)"
            )
            return 0
        }

        return UInt64(info.resident_size)
    }

    public func totalMemory() -> UInt64 {
        ProcessInfo.processInfo.physicalMemory
    }
}
