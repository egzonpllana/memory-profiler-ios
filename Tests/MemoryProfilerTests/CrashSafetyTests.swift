//
//  CrashSafetyTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Distributed
import XCTest
@testable import MemoryProfiler

/// Each test reproduces a condition that crashed the host app before the safety audit.
final class CrashSafetyTests: XCTestCase {

    private let location = SourceLocation(fileID: "Tests", line: 1, function: "test")

    func testExpectingDeallocationInsideDeinitDoesNotAbort() {
        let harness = LeakEngineHarness()
        autoreleasepool {
            _ = SelfExpectingObjCObject(engine: harness.engine)
        }
        harness.executor.runAll()

        XCTAssertTrue(harness.publisher.detectedLeaks.isEmpty)
    }

    func testActorIsTrackedWithoutAssociatedObjects() {
        let harness = LeakEngineHarness()
        let retained = TrackedActor()
        harness.expect(retained)
        autoreleasepool {
            harness.expect(TrackedActor())
        }
        harness.engine.trackInstance(retained, budget: 0, location: location)
        harness.executor.runAll()

        XCTAssertEqual(harness.publisher.detectedLeaks.count, 1)
        XCTAssertTrue(harness.publisher.budgetViolations.isEmpty)
    }

    func testDistributedActorIsTrackedWithoutAssociatedObjects() {
        let harness = LeakEngineHarness()
        let system = LocalTestingDistributedActorSystem()
        let retained = TrackedDistributedActor(actorSystem: system)
        harness.expect(retained)
        harness.executor.runAll()

        XCTAssertEqual(harness.publisher.detectedLeaks.count, 1)
    }

    func testNonFiniteAndExtremeThresholdsDoNotTrap() {
        let stats = MemoryStats(footprint: 10, peakFootprint: 10, availableBeforeLimit: .max, physicalMemory: .max)

        XCTAssertEqual(stats.limit, .max)
        XCTAssertEqual(ThresholdEvaluator.thresholdBytes(for: .fractionOfLimit(1), stats: stats), .max)
        let fallback = UInt64.scaled(.max, by: ThresholdEvaluator.fallbackFraction)
        XCTAssertEqual(ThresholdEvaluator.thresholdBytes(for: .fractionOfLimit(.nan), stats: stats), fallback)
        XCTAssertEqual(ThresholdEvaluator.thresholdBytes(for: .fractionOfLimit(-.infinity), stats: stats), fallback)
        XCTAssertNotNil(stats.usageOfLimit)
    }

    func testCensusTotalsSaturate() {
        let entries = [
            ClassCensusEntry(typeName: "A", instanceCount: .max, totalBytes: .max),
            ClassCensusEntry(typeName: "B", instanceCount: .max, totalBytes: .max)
        ]
        let census = HeapCensus(entries: entries, scope: .allTypes, takenAt: Date())

        XCTAssertEqual(census.totalInstances, .max)
        XCTAssertEqual(census.totalBytes, .max)
    }

    func testGrowthPolicyIsClampedToSafeRanges() {
        let policy = AllocationGrowthPolicy(
            sampleInterval: .zero,
            consecutiveIncreases: .max,
            minimumInstanceIncrease: .min
        )
        var analyzer = AllocationGrowthAnalyzer(policy: policy)
        let entry = ClassCensusEntry(typeName: "A", instanceCount: 1, totalBytes: 1)
        let census = HeapCensus(entries: [entry], scope: .allTypes, takenAt: Date())

        XCTAssertEqual(policy.sampleInterval, .seconds(1))
        XCTAssertEqual(policy.consecutiveIncreases, 1_000)
        XCTAssertEqual(policy.minimumInstanceIncrease, 1)
        XCTAssertTrue(analyzer.record(census).isEmpty)
    }

    func testSchedulerAcceptsExtremeIntervals() {
        let scheduler = DispatchRepeatingScheduler(label: "test.extreme")
        let fired = expectation(description: "first tick")
        fired.assertForOverFulfill = false
        scheduler.start(interval: .seconds(Int64.max)) { fired.fulfill() }
        wait(for: [fired], timeout: 2)
        scheduler.start(interval: .zero) {}
        scheduler.stop()

        XCTAssertFalse(scheduler.isActive)
    }

    func testObjectiveCBridgeSanitizesGracePeriods() {
        let object = NSObject()
        for seconds in [TimeInterval.infinity, -.infinity, .nan, -5, 1e300] {
            ObjCMemoryProfiler.expectDeallocation(of: object, within: seconds)
        }
        let reportType: AnyObject = ObjCLeakReport.self
        let created = reportType.perform(NSSelectorFromString("new"))?.takeRetainedValue() as? ObjCLeakReport

        XCTAssertEqual(created?.typeName, "")
    }

    func testCancellingAHandlerThatReleasesAnotherSubscriptionDoesNotReenterTheLock() {
        let broadcaster = MemoryEventBroadcaster(observers: [])
        let other = broadcaster.addHandler { _ in }
        var canceller: SubscriptionCanceller? = SubscriptionCanceller(other: other)
        let subscription = broadcaster.addHandler { [canceller] _ in _ = canceller }
        canceller = nil
        subscription.cancel()

        XCTAssertNil(canceller)
    }

    func testLoggerMayCallBackIntoTheProfilerWhileItStarts() {
        let logger = ReentrantLogger()
        var configuration = MemoryProfilerConfiguration(environment: .all)
        configuration.allocationGrowth = .enabled(AllocationGrowthPolicy())
        let harness = ServiceHarness(configuration: configuration, logger: logger)
        harness.heapCensus.isAvailable = false
        logger.attach(harness.service)
        harness.service.start()

        XCTAssertGreaterThanOrEqual(logger.callCount, 2)
        XCTAssertEqual(harness.service.state, .idle)
    }
}
