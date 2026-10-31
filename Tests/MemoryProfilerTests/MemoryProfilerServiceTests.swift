//
//  MemoryProfilerServiceTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import XCTest
@testable import MemoryProfiler

final class MemoryProfilerServiceTests: XCTestCase {

    func testStartRunsComponentsOnce() {
        let harness = ServiceHarness()
        harness.service.start()
        harness.service.start()

        XCTAssertEqual(harness.service.state, .monitoring)
        XCTAssertEqual(harness.monitoringScheduler.startCount, 1)
        XCTAssertEqual(harness.monitoringScheduler.lastInterval, .seconds(30))
        XCTAssertEqual(harness.automaticTracking.attachCount, 1)
        XCTAssertTrue(harness.pressureObserver.isObserving)
    }

    func testStopAndDisableStopComponents() {
        let harness = ServiceHarness()
        harness.service.start()
        harness.service.stop()
        XCTAssertEqual(harness.service.state, .idle)
        XCTAssertFalse(harness.monitoringScheduler.isActive)
        XCTAssertEqual(harness.automaticTracking.detachCount, 1)

        harness.service.start()
        harness.service.disable()
        XCTAssertEqual(harness.service.state, .disabled)
        XCTAssertFalse(harness.monitoringScheduler.isActive)
        XCTAssertNil(harness.service.currentStats())

        harness.service.enable()
        XCTAssertEqual(harness.service.state, .idle)
    }

    func testConfigureRestartsRunningComponents() {
        let harness = ServiceHarness()
        harness.service.start()
        var configuration = harness.service.configuration
        configuration.monitoring.interval = .seconds(5)
        harness.service.configure(configuration)

        XCTAssertEqual(harness.monitoringScheduler.startCount, 2)
        XCTAssertEqual(harness.monitoringScheduler.lastInterval, .seconds(5))
        XCTAssertEqual(harness.service.state, .monitoring)
    }

    func testManualExpectationWorksWithoutStart() {
        let harness = ServiceHarness()
        let viewModel = TrackedViewModel()
        harness.service.expectDeallocation(of: viewModel)
        harness.executor.runAll()

        XCTAssertEqual(harness.service.currentLeaks().count, 1)
    }

    func testDisabledServiceIgnoresExpectations() {
        let harness = ServiceHarness()
        harness.service.disable()
        let viewModel = TrackedViewModel()
        harness.service.expectDeallocation(of: viewModel)

        XCTAssertEqual(harness.executor.pendingCount, 0)
        XCTAssertThrowsError(try harness.service.heapCensus())
    }

    func testLogMemoryUsageIncludesContext() {
        let harness = ServiceHarness()
        harness.service.logMemoryUsage(context: "after import")
        let messages = (harness.logger as? MockMemoryLogger)?.messages ?? []

        XCTAssertTrue(messages.contains { $0.contains("footprint") && $0.contains("[after import]") })
    }

    func testThresholdEventIsDeliveredToHandler() {
        let harness = ServiceHarness()
        let delivered = expectation(description: "threshold event")
        harness.service.addEventHandler { event in
            if case .thresholdExceeded = event {
                delivered.fulfill()
            }
        }
        harness.reader.stub(footprint: 950, availableBeforeLimit: 50)
        harness.service.start()
        harness.monitoringScheduler.fire()

        wait(for: [delivered], timeout: 2)
    }
}
