//
//  LeakReport.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// An object that is still alive after its expected deallocation plus the grace period.
public struct LeakReport: Sendable, Equatable, Identifiable {

    // MARK: - Properties

    /// Stable identifier, shared with the matching `LeakResolution` if the object is released later.
    public let id: UUID

    /// The leaked object.
    public let object: ObjectDescriptor

    /// Where, when and why the object was expected to deallocate.
    public let expectation: DeallocationExpectationContext

    /// When the leak was confirmed.
    public let detectedAt: Date

    /// Who keeps the object alive, when retention analysis is enabled and available.
    public let retention: RetentionAnalysis?

    /// Time between the expectation and detection.
    public var overdueInterval: TimeInterval {
        detectedAt.timeIntervalSince(expectation.expectedAt)
    }

    // MARK: - Initialization

    /// Creates a leak report.
    ///
    /// - Parameters:
    ///   - id: Identifier. Defaults to a new UUID.
    ///   - object: The leaked object.
    ///   - expectation: Expectation context.
    ///   - detectedAt: Detection time.
    ///   - retention: Retention analysis, if any.
    public init(
        id: UUID = UUID(),
        object: ObjectDescriptor,
        expectation: DeallocationExpectationContext,
        detectedAt: Date,
        retention: RetentionAnalysis? = nil
    ) {
        self.id = id
        self.object = object
        self.expectation = expectation
        self.detectedAt = detectedAt
        self.retention = retention
    }

    /// A copy carrying `retention`.
    func withRetention(_ retention: RetentionAnalysis?) -> LeakReport {
        LeakReport(id: id, object: object, expectation: expectation, detectedAt: detectedAt, retention: retention)
    }
}
