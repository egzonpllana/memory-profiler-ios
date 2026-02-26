//
//  SnapshotDiffEngineTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import XCTest
@testable import MemoryProfiler

final class SnapshotDiffEngineTests: XCTestCase {

    func testNoLeaksWhenCountsAreStable() {
        let engine = SnapshotDiffEngine(consecutiveGrowthThreshold: 3)

        for _ in 0..<3 {
            engine.recordSnapshot(
                MemorySnapshot(
                    typeCounts: ["ViewModel": 5],
                    totalMemoryUsed: 1000
                )
            )
        }

        let leaks = engine.analyzeGrowth()
        XCTAssertTrue(leaks.isEmpty)
    }

    func testDetectsMonotonicallyGrowingType() {
        let engine = SnapshotDiffEngine(consecutiveGrowthThreshold: 3)

        for idx in 1...3 {
            engine.recordSnapshot(
                MemorySnapshot(
                    typeCounts: ["ViewModel": idx * 10],
                    totalMemoryUsed: UInt64(idx) * 1000
                )
            )
        }

        let leaks = engine.analyzeGrowth()
        XCTAssertEqual(leaks.count, 1)
        XCTAssertEqual(leaks.first?.objectType, "ViewModel")
        XCTAssertEqual(leaks.first?.objectCount, 30)
    }

    func testIgnoresNonGrowingTypes() {
        let engine = SnapshotDiffEngine(consecutiveGrowthThreshold: 3)

        let counts = [10, 8, 12]
        for count in counts {
            engine.recordSnapshot(
                MemorySnapshot(
                    typeCounts: ["Service": count],
                    totalMemoryUsed: 1000
                )
            )
        }

        let leaks = engine.analyzeGrowth()
        XCTAssertTrue(leaks.isEmpty)
    }

    func testResetClearsHistory() {
        let engine = SnapshotDiffEngine(consecutiveGrowthThreshold: 3)

        for idx in 1...3 {
            engine.recordSnapshot(
                MemorySnapshot(
                    typeCounts: ["ViewModel": idx * 10],
                    totalMemoryUsed: 1000
                )
            )
        }

        engine.reset()
        let leaks = engine.analyzeGrowth()
        XCTAssertTrue(leaks.isEmpty)
    }

    func testInsufficientSnapshotsReturnsEmpty() {
        let engine = SnapshotDiffEngine(consecutiveGrowthThreshold: 3)

        engine.recordSnapshot(
            MemorySnapshot(
                typeCounts: ["ViewModel": 10],
                totalMemoryUsed: 1000
            )
        )

        let leaks = engine.analyzeGrowth()
        XCTAssertTrue(leaks.isEmpty)
    }
}
