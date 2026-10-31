//
//  MemoryProfilerDependencies.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Every collaborator of the profiler, injectable for tests.
struct MemoryProfilerDependencies: Sendable {
    var memoryReader: any MemoryReading
    var monitoringScheduler: any RepeatingScheduling
    var growthScheduler: any RepeatingScheduling
    var pressureObserver: any MemoryPressureObserving
    var delayedExecutor: any DelayedExecuting
    var deallocationObserver: any DeallocationObserving
    var objectInspector: any ObjectInspecting
    var heapCensus: any HeapCensusTaking
    var referrerScanner: any ReferrerScanning
    var automaticTracking: any AutomaticTrackingInstalling
    var debuggerDetector: any DebuggerDetecting
    var clock: any TimeProviding
    var logger: any MemoryLogging

    /// The production implementations.
    static func live(logger: any MemoryLogging) -> MemoryProfilerDependencies {
        let clock = SystemTimeProvider()
        let classifier = RuntimeTypeOriginClassifier()
        return MemoryProfilerDependencies(
            memoryReader: MachMemoryReader(),
            monitoringScheduler: DispatchRepeatingScheduler(label: "com.egzonpllana.MemoryProfiler.monitoring"),
            growthScheduler: DispatchRepeatingScheduler(label: "com.egzonpllana.MemoryProfiler.growth"),
            pressureObserver: DispatchMemoryPressureObserver(),
            delayedExecutor: MainQueueDelayedExecutor(),
            deallocationObserver: AssociatedObjectDeallocationObserver(),
            objectInspector: RuntimeObjectInspector(),
            heapCensus: MallocHeapCensusReader(classifier: classifier, clock: clock),
            referrerScanner: MallocReferrerScanner(logger: logger, classifier: classifier),
            automaticTracking: PlatformAutomaticTracking.make(),
            debuggerDetector: SysctlDebuggerDetector(),
            clock: clock,
            logger: logger
        )
    }
}
