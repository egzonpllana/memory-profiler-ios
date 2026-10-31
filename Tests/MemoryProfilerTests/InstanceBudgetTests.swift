//
//  InstanceBudgetTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import XCTest
@testable import MemoryProfiler

final class InstanceBudgetTests: XCTestCase {

    private let location = SourceLocation(fileID: "Tests/Test.swift", line: 9, function: "init()")

    func testExceedingBudgetPublishesOnceAndRearms() {
        let harness = LeakEngineHarness()
        var first: TrackedViewModel? = TrackedViewModel()
        let second = TrackedViewModel()
        let third = TrackedViewModel()
        first.map { harness.engine.trackInstance($0, budget: 1, location: location) }
        harness.engine.trackInstance(second, budget: 1, location: location)
        harness.engine.trackInstance(third, budget: 1, location: location)

        XCTAssertEqual(harness.publisher.budgetViolations.count, 1)
        XCTAssertEqual(harness.publisher.budgetViolations.first?.liveCount, 2)

        first = nil
        let fourth = TrackedViewModel()
        harness.engine.trackInstance(fourth, budget: 1, location: location)
        XCTAssertEqual(harness.publisher.budgetViolations.count, 1)
        withExtendedLifetime((second, third, fourth)) {}
    }

    func testDuplicateTrackingIsCountedOnce() {
        let harness = LeakEngineHarness()
        let viewModel = TrackedViewModel()
        harness.engine.trackInstance(viewModel, budget: 1, location: location)
        harness.engine.trackInstance(viewModel, budget: 1, location: location)

        XCTAssertTrue(harness.publisher.budgetViolations.isEmpty)
    }

    func testBudgetRearmsAfterInstancesDeallocate() {
        let harness = LeakEngineHarness()
        autoreleasepool {
            let first = TrackedViewModel()
            let second = TrackedViewModel()
            harness.engine.trackInstance(first, budget: 1, location: location)
            harness.engine.trackInstance(second, budget: 1, location: location)
        }
        let third = TrackedViewModel()
        let fourth = TrackedViewModel()
        harness.engine.trackInstance(third, budget: 1, location: location)
        harness.engine.trackInstance(fourth, budget: 1, location: location)

        XCTAssertEqual(harness.publisher.budgetViolations.count, 2)
    }
}
