//
//  HeapCensusError.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Reasons a heap census or retention scan cannot run.
public enum HeapCensusError: Error, Sendable, Equatable, CustomStringConvertible {

    /// Heap introspection is compiled into debug builds only, or the runtime lacks the isa mask.
    case introspectionUnavailable

    /// The profiler is disabled or its environment excludes this build.
    case profilerInactive

    /// The malloc zones could not be enumerated.
    case zoneEnumerationFailed

    /// Scratch memory could not be allocated.
    case outOfMemory

    /// Human readable description.
    public var description: String {
        switch self {
        case .introspectionUnavailable:
            return "Heap introspection is unavailable (release build or unsupported runtime)."
        case .profilerInactive:
            return "The profiler is disabled or inactive in this build."
        case .zoneEnumerationFailed:
            return "The malloc zones could not be enumerated."
        case .outOfMemory:
            return "Scratch memory for the heap walk could not be allocated."
        }
    }
}
