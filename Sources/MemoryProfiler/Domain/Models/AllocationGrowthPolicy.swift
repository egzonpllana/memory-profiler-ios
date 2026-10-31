//
//  AllocationGrowthPolicy.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Thresholds for flagging classes whose live instance count keeps growing.
public struct AllocationGrowthPolicy: Sendable, Equatable {

    // MARK: - Properties

    /// Time between heap census samples.
    public let sampleInterval: Duration

    /// Number of consecutive samples in which the instance count must increase.
    public let consecutiveIncreases: Int

    /// Minimum total instance increase across the window.
    public let minimumInstanceIncrease: Int

    /// Classes considered by the analysis.
    public let scope: TypeScope

    // MARK: - Initialization

    /// Creates an allocation growth policy.
    ///
    /// Values are clamped to safe ranges: the sample interval to at least 1 second (each census
    /// pauses allocating threads), consecutive increases to 1...1000, the minimum increase to at least 1.
    ///
    /// - Parameters:
    ///   - sampleInterval: Time between census samples. Defaults to 60 seconds.
    ///   - consecutiveIncreases: Required consecutive increases. Defaults to 4.
    ///   - minimumInstanceIncrease: Minimum total increase across the window. Defaults to 5.
    ///   - scope: Classes considered. Defaults to `.applicationTypes`.
    public init(
        sampleInterval: Duration = .seconds(60),
        consecutiveIncreases: Int = 4,
        minimumInstanceIncrease: Int = 5,
        scope: TypeScope = .applicationTypes
    ) {
        self.sampleInterval = max(sampleInterval, .seconds(1))
        self.consecutiveIncreases = min(max(1, consecutiveIncreases), 1_000)
        self.minimumInstanceIncrease = max(1, minimumInstanceIncrease)
        self.scope = scope
    }
}
