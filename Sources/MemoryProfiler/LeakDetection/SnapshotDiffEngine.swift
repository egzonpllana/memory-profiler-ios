//
//  SnapshotDiffEngine.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

/// Detects potential leaks by comparing consecutive memory snapshots.
///
/// When a type's allocation count grows monotonically across a configurable
/// number of consecutive snapshots, it is flagged as a suspected leak.
public final class SnapshotDiffEngine {

    // MARK: - Properties

    private let lock = UnfairLock()
    private var history: [MemorySnapshot] = []
    private let consecutiveGrowthThreshold: Int

    // MARK: - Initialization

    /// Creates a snapshot diff engine.
    ///
    /// - Parameter consecutiveGrowthThreshold: Number of consecutive
    ///   snapshots where a type must grow to be flagged. Default is 3.
    public init(consecutiveGrowthThreshold: Int = 3) {
        self.consecutiveGrowthThreshold = consecutiveGrowthThreshold
    }

    // MARK: - Public Methods

    /// Records a new snapshot for analysis.
    ///
    /// - Parameter snapshot: The memory snapshot to add to history.
    public func recordSnapshot(_ snapshot: MemorySnapshot) {
        lock.withLock {
            history.append(snapshot)
            let maxHistory = consecutiveGrowthThreshold + 1
            if history.count > maxHistory {
                history.removeFirst(history.count - maxHistory)
            }
        }
    }

    /// Analyzes recorded snapshots for monotonically growing types.
    ///
    /// - Returns: Leak info for each type that grew across
    ///   all recent consecutive snapshots.
    public func analyzeGrowth() -> [MemoryLeakInfo] {
        lock.withLock {
            let recent = history.suffix(consecutiveGrowthThreshold)
            guard recent.count >= consecutiveGrowthThreshold else {
                return []
            }
            let snapshots = Array(recent)
            let allTypes = Set(snapshots.flatMap { $0.typeCounts.keys })
            return allTypes.compactMap { leakInfoForType($0, in: snapshots) }
        }
    }

    /// Clears all recorded snapshot history.
    public func reset() {
        lock.withLock { history.removeAll() }
    }

    // MARK: - Private Methods

    private func leakInfoForType(
        _ typeName: String,
        in snapshots: [MemorySnapshot]
    ) -> MemoryLeakInfo? {
        let counts = snapshots.compactMap { $0.typeCounts[typeName] }
        guard counts.count == consecutiveGrowthThreshold else { return nil }

        let isGrowing = zip(counts, counts.dropFirst()).allSatisfy {
            $0.1 > $0.0
        }
        guard isGrowing, let lastCount = counts.last else { return nil }

        return MemoryLeakInfo(
            objectType: typeName,
            objectCount: lastCount,
            memorySize: 0
        )
    }
}
