//
//  ThresholdEvaluator.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Edge-triggered threshold check with hysteresis, so a footprint hovering at the threshold
/// does not publish an event on every sample.
struct ThresholdEvaluator {

    // MARK: - Types

    private enum ThresholdState {
        case belowThreshold
        case aboveThreshold
    }

    // MARK: - Properties

    /// Fraction of the threshold the footprint must fall below to recover.
    static let recoveryRatio = 0.95

    private var state = ThresholdState.belowThreshold

    // MARK: - Public Methods

    /// Evaluates a sample and returns a transition when the state changes.
    mutating func evaluate(_ stats: MemoryStats, threshold: MemoryThreshold) -> ThresholdTransition? {
        let thresholdBytes = Self.thresholdBytes(for: threshold, stats: stats)
        switch state {
        case .belowThreshold:
            guard stats.footprint >= thresholdBytes else { return nil }
            state = .aboveThreshold
            return .exceeded
        case .aboveThreshold:
            guard Double(stats.footprint) < Double(thresholdBytes) * Self.recoveryRatio else { return nil }
            state = .belowThreshold
            return .recovered
        }
    }

    /// The threshold in bytes for a sample.
    static func thresholdBytes(for threshold: MemoryThreshold, stats: MemoryStats) -> UInt64 {
        switch threshold {
        case .bytes(let bytes):
            return bytes
        case .fractionOfLimit(let fraction):
            let base = stats.limit ?? stats.physicalMemory
            return UInt64(Double(base) * min(max(fraction, 0), 1))
        }
    }
}
