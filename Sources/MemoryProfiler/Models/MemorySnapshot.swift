//
//  MemorySnapshot.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

/// A point-in-time capture of object allocation counts and memory usage.
///
/// Used by the snapshot diff engine to detect monotonically growing
/// allocations that may indicate memory leaks.
public struct MemorySnapshot: Sendable {

    /// Object type names mapped to their current allocation count.
    public let typeCounts: [String: Int]

    /// Total memory used at the time of capture (bytes).
    public let totalMemoryUsed: UInt64

    /// When this snapshot was taken.
    public let timestamp: Date

    /// Creates a memory snapshot.
    ///
    /// - Parameters:
    ///   - typeCounts: Allocation counts keyed by type name.
    ///   - totalMemoryUsed: Total memory in use at capture time.
    public init(
        typeCounts: [String: Int],
        totalMemoryUsed: UInt64
    ) {
        self.typeCounts = typeCounts
        self.totalMemoryUsed = totalMemoryUsed
        self.timestamp = Date()
    }
}
