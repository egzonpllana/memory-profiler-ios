//
//  ServiceState.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Mutable state of a profiler instance.
struct ServiceState {
    var status: MonitoringState
    var configuration: MemoryProfilerConfiguration

    /// Whether manual APIs may run: enabled, and the environment includes this build.
    var isActive: Bool {
        status != .disabled && configuration.environment.isActiveInCurrentBuild
    }
}
