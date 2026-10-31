//
//  RetentionAnalysis.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Result of the experimental referrer scan for a leaked object.
///
/// The scan is conservative. Any pointer-sized word equal to an object's address counts as a
/// reference, so Objective-C `weak` and Swift `unowned` references appear as edges. Swift `weak`
/// references are excluded.
public struct RetentionAnalysis: Sendable, Equatable {

    // MARK: - Properties

    /// Referrers found, closest first.
    public let referrers: [RetentionReferrer]

    /// A cycle leading back to the leaked object, when one was found.
    public let cycle: RetentionCycle?

    /// Whether every referrer within the depth limit was recorded.
    public let completeness: RetentionAnalysisCompleteness

    // MARK: - Initialization

    /// Creates a retention analysis.
    ///
    /// - Parameters:
    ///   - referrers: Referrers, closest first.
    ///   - cycle: Detected cycle, if any.
    ///   - completeness: Whether the scan saw every referrer.
    public init(referrers: [RetentionReferrer], cycle: RetentionCycle?, completeness: RetentionAnalysisCompleteness) {
        self.referrers = referrers
        self.cycle = cycle
        self.completeness = completeness
    }
}
