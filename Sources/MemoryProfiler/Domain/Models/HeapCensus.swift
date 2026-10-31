//
//  HeapCensus.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Live instance counts per class, taken by walking every in-use malloc block.
///
/// Instances of generic classes are not counted: their runtime-created metadata is not
/// listed by the Objective-C runtime.
public struct HeapCensus: Sendable, Equatable {

    // MARK: - Properties

    /// Entries sorted by bytes held, largest first.
    public let entries: [ClassCensusEntry]

    /// Classes considered.
    public let scope: TypeScope

    /// When the census was taken.
    public let takenAt: Date

    /// Live instances across all entries.
    public var totalInstances: Int {
        entries.reduce(0) { $0.saturatingAdding($1.instanceCount) }
    }

    /// Bytes held across all entries.
    public var totalBytes: UInt64 {
        entries.reduce(0) { $0.saturatingAdding($1.totalBytes) }
    }

    // MARK: - Initialization

    /// Creates a heap census.
    ///
    /// - Parameters:
    ///   - entries: Entries sorted by bytes held, largest first.
    ///   - scope: Classes considered.
    ///   - takenAt: Census time.
    public init(entries: [ClassCensusEntry], scope: TypeScope, takenAt: Date) {
        self.entries = entries
        self.scope = scope
        self.takenAt = takenAt
    }

    /// A copy keeping the `limit` largest entries.
    func limited(to limit: Int) -> HeapCensus {
        HeapCensus(entries: Array(entries.prefix(max(0, limit))), scope: scope, takenAt: takenAt)
    }
}
