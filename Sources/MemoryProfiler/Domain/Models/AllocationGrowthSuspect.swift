//
//  AllocationGrowthSuspect.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A class whose live instance count increased in every recent heap census sample.
public struct AllocationGrowthSuspect: Sendable, Equatable {

    // MARK: - Properties

    /// Fully qualified type name.
    public let typeName: String

    /// Live instance counts across the analysis window, oldest first.
    public let instanceCounts: [Int]

    /// Bytes held by the live instances in the latest sample.
    public let totalBytes: UInt64

    /// When the growth was detected.
    public let detectedAt: Date

    // MARK: - Initialization

    /// Creates an allocation growth suspect.
    ///
    /// - Parameters:
    ///   - typeName: Fully qualified type name.
    ///   - instanceCounts: Counts across the window, oldest first.
    ///   - totalBytes: Bytes held in the latest sample.
    ///   - detectedAt: Detection time.
    public init(typeName: String, instanceCounts: [Int], totalBytes: UInt64, detectedAt: Date) {
        self.typeName = typeName
        self.instanceCounts = instanceCounts
        self.totalBytes = totalBytes
        self.detectedAt = detectedAt
    }
}
