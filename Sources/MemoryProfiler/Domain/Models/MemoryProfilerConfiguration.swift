//
//  MemoryProfilerConfiguration.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Complete configuration of a memory profiler.
public struct MemoryProfilerConfiguration: Sendable, Equatable {

    // MARK: - Properties

    /// Builds in which the profiler runs.
    public var environment: MemoryProfilerEnvironment

    /// Footprint sampling and memory pressure settings.
    public var monitoring: MonitoringConfiguration

    /// Lifecycle leak detection settings.
    public var leakDetection: LeakDetectionConfiguration

    /// Heap census based growth detection.
    public var allocationGrowth: AllocationGrowthDetection

    /// The default configuration: debug builds only, 30 second sampling, automatic UIKit tracking.
    public static let `default` = MemoryProfilerConfiguration()

    // MARK: - Initialization

    /// Creates a profiler configuration.
    ///
    /// - Parameters:
    ///   - environment: Builds in which the profiler runs. Defaults to `.debugOnly`.
    ///   - monitoring: Footprint sampling settings.
    ///   - leakDetection: Leak detection settings.
    ///   - allocationGrowth: Growth detection. Defaults to `.disabled`.
    public init(
        environment: MemoryProfilerEnvironment = .debugOnly,
        monitoring: MonitoringConfiguration = MonitoringConfiguration(),
        leakDetection: LeakDetectionConfiguration = LeakDetectionConfiguration(),
        allocationGrowth: AllocationGrowthDetection = .disabled
    ) {
        self.environment = environment
        self.monitoring = monitoring
        self.leakDetection = leakDetection
        self.allocationGrowth = allocationGrowth
    }
}
