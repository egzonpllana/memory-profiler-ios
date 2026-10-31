//
//  LeakDetectionEngineTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import XCTest
@testable import MemoryProfiler

final class LeakDetectionEngineTests: XCTestCase {

    func testObjectReleasedBeforeDeadlineIsNotReported() {
        let harness = LeakEngineHarness()
        autoreleasepool {
            harness.expect(TrackedViewModel())
        }
        harness.executor.runAll()

        XCTAssertTrue(harness.publisher.events.isEmpty)
        XCTAssertTrue(harness.engine.currentLeaks().isEmpty)
    }

    func testObjectAliveAtDeadlineIsReportedOnce() {
        let harness = LeakEngineHarness()
        let viewModel = TrackedViewModel()
        harness.expect(viewModel)
        harness.expect(viewModel)

        XCTAssertEqual(harness.executor.pendingCount, 1)
        harness.executor.runAll()

        let report = harness.publisher.detectedLeaks.first
        XCTAssertEqual(harness.publisher.detectedLeaks.count, 1)
        XCTAssertEqual(report?.object.typeName, "MemoryProfilerTests.TrackedViewModel")
        XCTAssertGreaterThan(report?.object.allocationSize ?? 0, 0)
        XCTAssertEqual(report?.expectation.location.line, 1)
        XCTAssertEqual(harness.engine.currentLeaks().count, 1)
    }

    func testLateReleasePublishesResolution() {
        let harness = LeakEngineHarness()
        var viewModel: TrackedViewModel? = TrackedViewModel()
        if let viewModel {
            harness.expect(viewModel)
        }
        harness.executor.runAll()
        harness.clock.advance(by: 5)
        viewModel = nil

        XCTAssertEqual(harness.publisher.resolutions.count, 1)
        XCTAssertEqual(harness.publisher.resolutions.first?.retainedFor ?? 0, 5, accuracy: 0.001)
        XCTAssertTrue(harness.engine.currentLeaks().isEmpty)
    }

    func testExemptAndIgnoredObjectsAreNotTracked() {
        let filter = LeakDetectionFilter(ignoredTypeNames: ["MemoryProfilerTests.TrackedObjCObject"])
        let harness = LeakEngineHarness(configuration: LeakDetectionConfiguration(filter: filter))
        let cache = ExemptCache()
        let ignored = TrackedObjCObject()
        harness.expect(cache)
        harness.expect(ignored)

        XCTAssertEqual(harness.executor.pendingCount, 0)
    }

    func testUsageProbeCancelsExpectation() {
        let harness = LeakEngineHarness()
        let viewModel = TrackedViewModel()
        harness.expect(viewModel, probe: StubUsageProbe(isInUse: true))
        harness.executor.runAll()

        XCTAssertTrue(harness.publisher.events.isEmpty)
    }

    func testCustomGracePeriodIsScheduled() {
        let harness = LeakEngineHarness(configuration: LeakDetectionConfiguration(gracePeriod: .seconds(7)))
        let viewModel = TrackedViewModel()
        harness.expect(viewModel)

        XCTAssertEqual(harness.executor.delays, [.seconds(7)])
    }

    func testResetDropsPendingExpectations() {
        let harness = LeakEngineHarness()
        let viewModel = TrackedViewModel()
        harness.expect(viewModel)
        harness.engine.reset()
        harness.executor.runAll()

        XCTAssertTrue(harness.publisher.events.isEmpty)
    }
}
