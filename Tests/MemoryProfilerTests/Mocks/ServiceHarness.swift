//
//  ServiceHarness.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

/// A profiler wired to mocks.
struct ServiceHarness {
    let service: MemoryProfilerService
    let reader = MockMemoryReader()
    let monitoringScheduler = MockRepeatingScheduler()
    let growthScheduler = MockRepeatingScheduler()
    let pressureObserver = MockPressureObserver()
    let executor = ManualDelayedExecutor()
    let heapCensus = MockHeapCensus()
    let automaticTracking = MockAutomaticTracking()
    let logger = MockMemoryLogger()

    init(configuration: MemoryProfilerConfiguration = MemoryProfilerConfiguration(environment: .all)) {
        let dependencies = MemoryProfilerDependencies(
            memoryReader: reader,
            monitoringScheduler: monitoringScheduler,
            growthScheduler: growthScheduler,
            pressureObserver: pressureObserver,
            delayedExecutor: executor,
            deallocationObserver: AssociatedObjectDeallocationObserver(),
            objectInspector: RuntimeObjectInspector(),
            heapCensus: heapCensus,
            referrerScanner: StubReferrerScanner(analysis: nil),
            automaticTracking: automaticTracking,
            debuggerDetector: MockDebuggerDetector(),
            clock: FixedTimeProvider(),
            logger: logger
        )
        service = MemoryProfilerService(configuration: configuration, dependencies: dependencies)
    }
}
