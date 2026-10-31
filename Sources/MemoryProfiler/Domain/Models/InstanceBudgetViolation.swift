//
//  InstanceBudgetViolation.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// More live instances of a type than its declared budget.
public struct InstanceBudgetViolation: Sendable, Equatable {

    // MARK: - Properties

    /// Fully qualified type name.
    public let typeName: String

    /// Live instances when the budget was exceeded.
    public let liveCount: Int

    /// Declared maximum number of live instances.
    public let budget: Int

    /// Source position of the `trackInstance` call that exceeded the budget.
    public let location: SourceLocation

    /// When the budget was exceeded.
    public let detectedAt: Date

    // MARK: - Initialization

    /// Creates an instance budget violation.
    ///
    /// - Parameters:
    ///   - typeName: Fully qualified type name.
    ///   - liveCount: Live instances.
    ///   - budget: Declared budget.
    ///   - location: Source position of the exceeding `trackInstance` call.
    ///   - detectedAt: Detection time.
    public init(typeName: String, liveCount: Int, budget: Int, location: SourceLocation, detectedAt: Date) {
        self.typeName = typeName
        self.liveCount = liveCount
        self.budget = budget
        self.location = location
        self.detectedAt = detectedAt
    }
}
