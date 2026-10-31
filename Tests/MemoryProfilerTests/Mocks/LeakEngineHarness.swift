//
//  LeakEngineHarness.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

/// Leak engine wired to manual collaborators.
struct LeakEngineHarness {
    let engine: LeakDetectionEngine
    let executor = ManualDelayedExecutor()
    let publisher = RecordingEventPublisher()
    let clock = FixedTimeProvider()
    let scanner: StubReferrerScanner

    init(configuration: LeakDetectionConfiguration = LeakDetectionConfiguration(), analysis: RetentionAnalysis? = nil) {
        let scanner = StubReferrerScanner(analysis: analysis)
        self.scanner = scanner
        engine = LeakDetectionEngine(
            configuration: configuration,
            dependencies: LeakDetectionDependencies(
                deallocationObserver: AssociatedObjectDeallocationObserver(),
                delayedExecutor: executor,
                inspector: RuntimeObjectInspector(),
                clock: clock,
                publisher: publisher,
                referrerScanner: scanner
            )
        )
    }

    func expect(_ object: AnyObject, probe: (any ObjectUsageProbing)? = nil) {
        let location = SourceLocation(fileID: "Tests/Test.swift", line: 1, function: "test()")
        let request = DeallocationRequest(gracePeriod: nil, reason: .manual, location: location, usageProbe: probe)
        engine.expectDeallocation(of: object, request: request)
    }
}
