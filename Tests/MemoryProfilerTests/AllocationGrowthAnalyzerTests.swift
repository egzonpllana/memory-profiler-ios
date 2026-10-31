//
//  AllocationGrowthAnalyzerTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import XCTest
@testable import MemoryProfiler

final class AllocationGrowthAnalyzerTests: XCTestCase {

    private let policy = AllocationGrowthPolicy(consecutiveIncreases: 3, minimumInstanceIncrease: 5)

    private func census(_ counts: [String: Int]) -> HeapCensus {
        let entries = counts.keys.sorted().map { name in
            let count = counts[name] ?? 0
            return ClassCensusEntry(typeName: name, instanceCount: count, totalBytes: UInt64(count * 64))
        }
        return HeapCensus(entries: entries, scope: .applicationTypes, takenAt: Date())
    }

    func testFlagsTypeGrowingAcrossWindowOnce() {
        var analyzer = AllocationGrowthAnalyzer(policy: policy)
        let results = [10, 12, 15, 19, 22].map { analyzer.record(census(["App.Cache": $0])) }

        XCTAssertTrue(results[0].isEmpty && results[1].isEmpty && results[2].isEmpty)
        XCTAssertEqual(results[3].first?.instanceCounts, [10, 12, 15, 19])
        XCTAssertTrue(results[4].isEmpty)
    }

    func testIgnoresGrowthBelowMinimumIncrease() {
        var analyzer = AllocationGrowthAnalyzer(policy: policy)
        let results = [10, 11, 12, 13].map { analyzer.record(census(["App.Cache": $0])) }

        XCTAssertTrue(results.allSatisfy(\.isEmpty))
    }

    func testRearmsAfterGrowthStops() {
        var analyzer = AllocationGrowthAnalyzer(policy: policy)
        let counts = [10, 12, 15, 19, 18, 21, 25, 30]
        let flagged = counts.map { analyzer.record(census(["App.Cache": $0])).count }

        XCTAssertEqual(flagged, [0, 0, 0, 1, 0, 0, 0, 1])
    }

    func testIgnoresStableOrShrinkingTypes() {
        var analyzer = AllocationGrowthAnalyzer(policy: policy)
        let results = [10, 10, 9, 10].map { analyzer.record(census(["App.Service": $0])) }

        XCTAssertTrue(results.allSatisfy(\.isEmpty))
    }
}
