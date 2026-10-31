//
//  MemoryProfilerEvent.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Everything the profiler reports.
public enum MemoryProfilerEvent: Sendable, Equatable {

    /// An object outlived its expected deallocation plus the grace period.
    case leakDetected(LeakReport)

    /// A reported object was released later: a late release, not a permanent leak.
    case leakResolved(LeakResolution)

    /// A type has more live instances than its declared budget.
    case instanceBudgetExceeded(InstanceBudgetViolation)

    /// A class kept accumulating instances across heap census samples.
    case allocationGrowthDetected(AllocationGrowthSuspect)

    /// The footprint crossed the warning threshold.
    case thresholdExceeded(MemoryStats)

    /// The footprint fell back below the warning threshold.
    case thresholdRecovered(MemoryStats)

    /// The system reported a change in memory pressure.
    case systemMemoryPressure(MemoryPressureLevel)
}
