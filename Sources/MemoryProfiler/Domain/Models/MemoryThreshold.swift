//
//  MemoryThreshold.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Footprint level above which the profiler publishes `thresholdExceeded`.
public enum MemoryThreshold: Sendable, Equatable {

    /// A fraction (0...1) of the process memory limit.
    ///
    /// On iOS, tvOS and visionOS the limit is the jetsam limit (footprint plus available memory).
    /// On macOS, where there is no per-process limit, physical memory is used instead.
    case fractionOfLimit(Double)

    /// An absolute footprint in bytes.
    case bytes(UInt64)
}
