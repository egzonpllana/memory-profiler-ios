//
//  AllocationGrowthAnalyzer.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Flags classes whose live instance count increased in every sample of the analysis window.
///
/// Each class is reported once per growth streak and re-armed when the streak breaks.
struct AllocationGrowthAnalyzer {

    // MARK: - Properties

    private let policy: AllocationGrowthPolicy
    private var history: [String: [Int]] = [:]
    private var flaggedTypes: Set<String> = []

    private var windowSize: Int {
        policy.consecutiveIncreases + 1
    }

    // MARK: - Initialization

    init(policy: AllocationGrowthPolicy) {
        self.policy = policy
    }

    // MARK: - Public Methods

    /// Records a census and returns the classes that just started growing.
    mutating func record(_ census: HeapCensus) -> [AllocationGrowthSuspect] {
        let present = Set(census.entries.map(\.typeName))
        history = history.filter { present.contains($0.key) }
        flaggedTypes.formIntersection(present)
        var suspects: [AllocationGrowthSuspect] = []
        for entry in census.entries {
            if let suspect = evaluate(entry, at: census.takenAt) {
                suspects.append(suspect)
            }
        }
        return suspects
    }

    // MARK: - Private Methods

    private mutating func evaluate(_ entry: ClassCensusEntry, at date: Date) -> AllocationGrowthSuspect? {
        let counts = Array(((history[entry.typeName] ?? []) + [entry.instanceCount]).suffix(windowSize))
        history[entry.typeName] = counts
        guard isGrowing(counts) else {
            flaggedTypes.remove(entry.typeName)
            return nil
        }
        guard flaggedTypes.insert(entry.typeName).inserted else { return nil }
        return AllocationGrowthSuspect(
            typeName: entry.typeName,
            instanceCounts: counts,
            totalBytes: entry.totalBytes,
            detectedAt: date
        )
    }

    private func isGrowing(_ counts: [Int]) -> Bool {
        guard counts.count == windowSize, let first = counts.first, let last = counts.last else { return false }
        let increasesEverySample = counts.indices.dropFirst().allSatisfy { counts[$0] > counts[$0 - 1] }
        return increasesEverySample && last - first >= policy.minimumInstanceIncrease
    }
}
