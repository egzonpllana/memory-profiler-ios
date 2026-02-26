//
//  MemoryProfilerServiceTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import XCTest
@testable import MemoryProfiler

final class MemoryProfilerServiceTests: XCTestCase {

    // MARK: - Test Dependencies

    private struct TestContext {
        let service: MemoryProfilerService
        let monitor: MockMemoryMonitor
        let scheduler: MockScheduler
        let leakDetector: MockLeakDetector
        let logger: MockMemoryLogger
    }

    private func makeSUT(
        isEnabled: Bool = true,
        monitor: MockMemoryMonitor = MockMemoryMonitor(),
        scheduler: MockScheduler = MockScheduler(),
        leakDetector: MockLeakDetector = MockLeakDetector(),
        logger: MockMemoryLogger = MockMemoryLogger()
    ) -> TestContext {
        let service = MemoryProfilerService(
            isEnabled: isEnabled,
            environment: .all,
            monitor: monitor,
            scheduler: scheduler,
            leakDetector: leakDetector,
            logger: logger
        )
        return TestContext(
            service: service,
            monitor: monitor,
            scheduler: scheduler,
            leakDetector: leakDetector,
            logger: logger
        )
    }

    // MARK: - Monitoring

    func testStartMonitoringCallsScheduler() {
        let ctx = makeSUT()
        ctx.service.startMonitoring()
        XCTAssertEqual(ctx.scheduler.startCallCount, 1)
        XCTAssertEqual(ctx.scheduler.lastInterval, 60.0)
    }

    func testStopMonitoringCallsScheduler() {
        let ctx = makeSUT()
        ctx.service.startMonitoring()
        ctx.service.stopMonitoring()
        XCTAssertEqual(ctx.scheduler.stopCallCount, 1)
    }

    func testDoubleStartDoesNotCallSchedulerTwice() {
        let ctx = makeSUT()
        ctx.service.startMonitoring()
        ctx.service.startMonitoring()
        XCTAssertEqual(ctx.scheduler.startCallCount, 1)
    }

    // MARK: - Memory Stats

    func testGetMemoryStatsUsesMonitor() {
        let monitor = MockMemoryMonitor()
        monitor.stubbedUsage = 200_000_000
        monitor.stubbedTotal = 4_000_000_000
        let ctx = makeSUT(monitor: monitor)

        let stats = ctx.service.getMemoryStats()

        XCTAssertEqual(stats.usedMemory, 200_000_000)
        XCTAssertEqual(stats.totalMemory, 4_000_000_000)
        XCTAssertEqual(stats.availableMemory, 3_800_000_000)
    }

    func testPeakMemoryIsTracked() {
        let monitor = MockMemoryMonitor()
        let ctx = makeSUT(monitor: monitor)

        monitor.stubbedUsage = 300_000_000
        _ = ctx.service.getMemoryStats()

        monitor.stubbedUsage = 100_000_000
        let stats = ctx.service.getMemoryStats()

        XCTAssertEqual(stats.peakMemoryUsage, 300_000_000)
    }

    // MARK: - Leak Detection

    func testDetectMemoryLeaksDelegatesToDetector() {
        let detector = MockLeakDetector()
        let leak = MemoryLeakInfo(
            objectType: "TestVM",
            objectCount: 1,
            memorySize: 1024
        )
        detector.stubbedLeaks = [leak]
        let ctx = makeSUT(leakDetector: detector)

        let leaks = ctx.service.detectMemoryLeaks()
        XCTAssertEqual(leaks.count, 1)
        XCTAssertEqual(leaks.first?.objectType, "TestVM")
    }

    func testTrackObjectDelegatesToDetector() {
        let detector = MockLeakDetector()
        let ctx = makeSUT(leakDetector: detector)
        let object = NSObject()

        ctx.service.trackObject(object, expectedLifetime: .scopeBound)
        XCTAssertEqual(detector.trackedObjects.count, 1)
    }

    // MARK: - Enable / Disable

    func testDisabledServiceReturnsEmptyStats() {
        let ctx = makeSUT(isEnabled: false)
        let stats = ctx.service.getMemoryStats()
        XCTAssertEqual(stats.usedMemory, 0)
    }

    func testDisableStopsMonitoring() {
        let ctx = makeSUT()
        ctx.service.startMonitoring()
        ctx.service.disable()
        XCTAssertEqual(ctx.scheduler.stopCallCount, 1)
        XCTAssertFalse(ctx.service.isServiceEnabled)
    }

    func testEnableAfterDisable() {
        let ctx = makeSUT()
        ctx.service.disable()
        XCTAssertFalse(ctx.service.isServiceEnabled)
        ctx.service.enable()
        XCTAssertTrue(ctx.service.isServiceEnabled)
    }

    // MARK: - Logging

    func testLogMemoryUsageOutputsToLogger() {
        let logger = MockMemoryLogger()
        let ctx = makeSUT(logger: logger)

        ctx.service.logMemoryUsage(context: "test")

        let hasMemoryLog = logger.loggedMessages.contains {
            $0.contains("Memory:") && $0.contains("[test]")
        }
        XCTAssertTrue(hasMemoryLog)
    }

    // MARK: - Threshold Warning

    func testThresholdWarningIsLogged() {
        let monitor = MockMemoryMonitor()
        monitor.stubbedUsage = 3_500_000_000
        monitor.stubbedTotal = 4_000_000_000
        let scheduler = MockScheduler()
        let logger = MockMemoryLogger()
        let ctx = makeSUT(
            monitor: monitor,
            scheduler: scheduler,
            logger: logger
        )

        ctx.service.startMonitoring()
        scheduler.simulateTick()

        let hasWarning = logger.loggedWarnings.contains {
            $0.contains("exceeded threshold")
        }
        XCTAssertTrue(hasWarning)
    }
}
