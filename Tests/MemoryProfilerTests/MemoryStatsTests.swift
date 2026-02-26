//
//  MemoryStatsTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import XCTest
@testable import MemoryProfiler

final class MemoryStatsTests: XCTestCase {

    func testPercentageCalculation() {
        let stats = MemoryStats(
            usedMemory: 500,
            availableMemory: 500,
            totalMemory: 1000,
            peakMemoryUsage: 600
        )

        XCTAssertEqual(stats.memoryUsagePercentage, 50.0, accuracy: 0.01)
    }

    func testPercentageWithZeroTotal() {
        let stats = MemoryStats(
            usedMemory: 0,
            availableMemory: 0,
            totalMemory: 0,
            peakMemoryUsage: 0
        )

        XCTAssertEqual(stats.memoryUsagePercentage, 0)
    }

    func testTimestampIsPopulated() {
        let before = Date()
        let stats = MemoryStats(
            usedMemory: 100,
            availableMemory: 900,
            totalMemory: 1000,
            peakMemoryUsage: 100
        )
        let after = Date()

        XCTAssertGreaterThanOrEqual(stats.timestamp, before)
        XCTAssertLessThanOrEqual(stats.timestamp, after)
    }
}
