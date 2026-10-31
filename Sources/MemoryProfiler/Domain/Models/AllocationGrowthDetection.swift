//
//  AllocationGrowthDetection.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Whether the profiler samples the heap to find classes that keep accumulating instances.
public enum AllocationGrowthDetection: Sendable, Equatable {

    /// No heap sampling.
    case disabled

    /// Samples the heap with the given policy. Debug builds only; each census briefly
    /// pauses every allocating thread.
    case enabled(AllocationGrowthPolicy)
}
