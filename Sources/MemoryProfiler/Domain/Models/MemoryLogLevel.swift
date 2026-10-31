//
//  MemoryLogLevel.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Severity of a profiler log message.
public enum MemoryLogLevel: Sendable, Equatable, Comparable {

    /// Verbose diagnostics such as periodic samples.
    case debug

    /// Lifecycle and informational messages.
    case info

    /// Conditions that need attention, such as threshold crossings.
    case warning

    /// Confirmed problems, such as leaked objects.
    case error
}
