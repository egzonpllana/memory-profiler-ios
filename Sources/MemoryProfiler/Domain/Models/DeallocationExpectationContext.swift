//
//  DeallocationExpectationContext.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Where, when and why an object was expected to deallocate.
public struct DeallocationExpectationContext: Sendable, Equatable {

    // MARK: - Properties

    /// Why the object was expected to deallocate.
    public let reason: DeallocationExpectationReason

    /// Source position of the expectation.
    public let location: SourceLocation

    /// When the expectation was registered; the grace period starts here.
    public let expectedAt: Date

    /// Call stack at the expectation, when capture is enabled.
    public let callStack: [String]

    // MARK: - Initialization

    /// Creates an expectation context.
    ///
    /// - Parameters:
    ///   - reason: Why the object was expected to deallocate.
    ///   - location: Source position of the expectation.
    ///   - expectedAt: When the expectation was registered.
    ///   - callStack: Captured call stack, empty when capture is disabled.
    public init(
        reason: DeallocationExpectationReason,
        location: SourceLocation,
        expectedAt: Date,
        callStack: [String]
    ) {
        self.reason = reason
        self.location = location
        self.expectedAt = expectedAt
        self.callStack = callStack
    }
}
