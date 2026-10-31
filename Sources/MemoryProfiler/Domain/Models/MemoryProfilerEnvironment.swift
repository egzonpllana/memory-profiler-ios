//
//  MemoryProfilerEnvironment.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Build environments in which the profiler is allowed to run.
public enum MemoryProfilerEnvironment: Sendable, Equatable {

    /// Runs only when the package is compiled in the debug configuration.
    case debugOnly

    /// Runs in every build configuration, including release builds used for QA or staging.
    case all

    /// Whether the profiler may run in the current build.
    public var isActiveInCurrentBuild: Bool {
        switch self {
        case .all:
            return true
        case .debugOnly:
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }
}
