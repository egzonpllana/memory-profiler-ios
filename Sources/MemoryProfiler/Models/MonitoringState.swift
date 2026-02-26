//
//  MonitoringState.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

/// Represents the lifecycle state of the memory profiler.
public enum MonitoringState: Sendable {
    /// The profiler is initialized but not actively monitoring.
    case idle
    /// The profiler is actively monitoring memory usage.
    case monitoring
    /// The profiler has been disabled and will not perform operations.
    case disabled
}
