//
//  ThresholdEvaluatorTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import XCTest
@testable import MemoryProfiler

final class ThresholdEvaluatorTests: XCTestCase {

    private func stats(footprint: UInt64, available: UInt64? = nil) -> MemoryStats {
        MemoryStats(
            footprint: footprint,
            peakFootprint: footprint,
            availableBeforeLimit: available,
            physicalMemory: 1_000
        )
    }

    func testPublishesTransitionsOnlyOnEdges() {
        var evaluator = ThresholdEvaluator()
        let threshold = MemoryThreshold.bytes(800)
        let transitions = [500, 800, 900, 780, 750, 820].map {
            evaluator.evaluate(stats(footprint: UInt64($0)), threshold: threshold)
        }

        XCTAssertEqual(transitions, [nil, .exceeded, nil, nil, .recovered, .exceeded])
    }

    func testFractionUsesProcessLimitWhenKnown() {
        let sample = stats(footprint: 400, available: 600)

        XCTAssertEqual(ThresholdEvaluator.thresholdBytes(for: .fractionOfLimit(0.5), stats: sample), 500)
    }

    func testFractionFallsBackToPhysicalMemory() {
        let sample = stats(footprint: 400)

        XCTAssertEqual(ThresholdEvaluator.thresholdBytes(for: .fractionOfLimit(0.7), stats: sample), 700)
    }
}
