//
//  MonitoringState.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Lifecycle state of the memory profiler.
public enum MonitoringState: Sendable, Equatable {

    /// Enabled but not monitoring. Manual leak expectations still work.
    case idle

    /// Periodic monitoring, pressure observation and automatic leak tracking are running.
    case monitoring

    /// Disabled. Every operation is a no-op until `enable()` is called.
    case disabled
}
