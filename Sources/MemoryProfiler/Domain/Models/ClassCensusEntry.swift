//
//  ClassCensusEntry.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Live instances of one class in a heap census.
public struct ClassCensusEntry: Sendable, Equatable {

    // MARK: - Properties

    /// Fully qualified type name.
    public let typeName: String

    /// Live instances.
    public let instanceCount: Int

    /// Bytes held by the instances' heap allocations.
    public let totalBytes: UInt64

    // MARK: - Initialization

    /// Creates a census entry.
    ///
    /// - Parameters:
    ///   - typeName: Fully qualified type name.
    ///   - instanceCount: Live instances.
    ///   - totalBytes: Bytes held.
    public init(typeName: String, instanceCount: Int, totalBytes: UInt64) {
        self.typeName = typeName
        self.instanceCount = instanceCount
        self.totalBytes = totalBytes
    }
}
