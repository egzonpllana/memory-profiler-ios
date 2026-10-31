//
//  LeakResolution.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A previously reported object that was eventually released: a late release, not a permanent leak.
public struct LeakResolution: Sendable, Equatable {

    // MARK: - Properties

    /// The original report.
    public let report: LeakReport

    /// When the object deallocated.
    public let releasedAt: Date

    /// Time the object stayed alive after it was expected to deallocate.
    public var retainedFor: TimeInterval {
        releasedAt.timeIntervalSince(report.expectation.expectedAt)
    }

    // MARK: - Initialization

    /// Creates a leak resolution.
    ///
    /// - Parameters:
    ///   - report: The original report.
    ///   - releasedAt: Deallocation time.
    public init(report: LeakReport, releasedAt: Date) {
        self.report = report
        self.releasedAt = releasedAt
    }
}
