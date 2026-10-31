//
//  MonitoringConfiguration.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Settings for periodic footprint sampling and memory pressure observation.
public struct MonitoringConfiguration: Sendable, Equatable {

    // MARK: - Properties

    /// Time between footprint samples.
    public var interval: Duration

    /// Footprint level that triggers `thresholdExceeded`.
    public var warningThreshold: MemoryThreshold

    /// Whether system memory pressure notifications are published as events.
    public var observesSystemMemoryPressure: Bool

    // MARK: - Initialization

    /// Creates a monitoring configuration.
    ///
    /// - Parameters:
    ///   - interval: Time between footprint samples. Defaults to 30 seconds.
    ///   - warningThreshold: Threshold for footprint warnings. Defaults to 80% of the memory limit.
    ///   - observesSystemMemoryPressure: Whether to publish system memory pressure events. Defaults to `true`.
    public init(
        interval: Duration = .seconds(30),
        warningThreshold: MemoryThreshold = .fractionOfLimit(0.8),
        observesSystemMemoryPressure: Bool = true
    ) {
        self.interval = interval
        self.warningThreshold = warningThreshold
        self.observesSystemMemoryPressure = observesSystemMemoryPressure
    }
}
