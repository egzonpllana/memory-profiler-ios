//
//  TimerBasedSchedulerTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import XCTest
@testable import MemoryProfiler

final class TimerBasedSchedulerTests: XCTestCase {

    func testStartSetsIsActive() {
        let scheduler = TimerBasedScheduler()
        scheduler.start(interval: 1.0) {}
        XCTAssertTrue(scheduler.isActive)
        scheduler.stop()
    }

    func testStopClearsIsActive() {
        let scheduler = TimerBasedScheduler()
        scheduler.start(interval: 1.0) {}
        scheduler.stop()
        XCTAssertFalse(scheduler.isActive)
    }

    func testHandlerIsCalled() {
        let scheduler = TimerBasedScheduler()
        let expectation = expectation(description: "handler called")

        scheduler.start(interval: 0.1) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        scheduler.stop()
    }

    func testRestartReplacesTimer() {
        let scheduler = TimerBasedScheduler()
        var firstHandlerCalled = false

        scheduler.start(interval: 10.0) {
            firstHandlerCalled = true
        }

        let expectation = expectation(description: "second handler")
        scheduler.start(interval: 0.1) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(firstHandlerCalled)
        scheduler.stop()
    }
}
