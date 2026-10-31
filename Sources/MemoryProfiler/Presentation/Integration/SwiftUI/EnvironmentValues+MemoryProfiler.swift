//
//  EnvironmentValues+MemoryProfiler.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#if canImport(SwiftUI)
import SwiftUI

private struct MemoryProfilerEnvironmentKey: EnvironmentKey {
    static let defaultValue: any MemoryProfilerServicing = MemoryProfilerService.shared
}

extension EnvironmentValues {

    /// The profiler used by `detectLeaks(of:)`. Defaults to `MemoryProfilerService.shared`.
    public var memoryProfiler: any MemoryProfilerServicing {
        get { self[MemoryProfilerEnvironmentKey.self] }
        set { self[MemoryProfilerEnvironmentKey.self] = newValue }
    }
}
#endif
