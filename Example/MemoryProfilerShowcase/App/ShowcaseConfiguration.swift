//
//  ShowcaseConfiguration.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import MemoryProfiler

/// Profiler settings tuned so every feature shows up within seconds.
enum ShowcaseConfiguration {

    /// Footprint above the launch baseline that triggers the threshold warning.
    static let thresholdHeadroom: UInt64 = 200 * 1_024 * 1_024

    static func make(baselineFootprint: UInt64?) -> MemoryProfilerConfiguration {
        var configuration = MemoryProfilerConfiguration()
        configuration.monitoring.interval = .seconds(2)
        configuration.monitoring.warningThreshold = .bytes((baselineFootprint ?? 0) + thresholdHeadroom)
        configuration.leakDetection.gracePeriod = .seconds(2)
        configuration.leakDetection.diagnostics.retentionAnalysis = .referrerScan(maxDepth: 3)
        configuration.allocationGrowth = .enabled(
            AllocationGrowthPolicy(sampleInterval: .seconds(1), consecutiveIncreases: 3, minimumInstanceIncrease: 5)
        )
        return configuration
    }
}
