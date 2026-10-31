//
//  ProfilerComponents.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// The profiler's object graph, built from its dependencies.
struct ProfilerComponents: Sendable {

    // MARK: - Properties

    let leakDetector: any LeakDetecting
    let monitoring: MemoryMonitoringCoordinator
    let allocationGrowth: AllocationGrowthCoordinator
    let broadcaster: MemoryEventBroadcaster
    let diagnostics: EventDiagnosticsReporter
    let memoryReader: any MemoryReading
    let heapCensus: any HeapCensusTaking
    let automaticTracking: any AutomaticTrackingInstalling
    let logger: any MemoryLogging

    // MARK: - Initialization

    init(configuration: MemoryProfilerConfiguration, dependencies: MemoryProfilerDependencies) {
        let alertHandler = LeakAlertHandler(debuggerDetector: dependencies.debuggerDetector)
        let diagnostics = EventDiagnosticsReporter(logger: dependencies.logger, alertHandler: alertHandler)
        let broadcaster = MemoryEventBroadcaster(observers: [diagnostics])
        self.diagnostics = diagnostics
        self.broadcaster = broadcaster
        leakDetector = Self.makeLeakDetector(configuration.leakDetection, dependencies, broadcaster)
        monitoring = Self.makeMonitoring(dependencies, broadcaster)
        allocationGrowth = AllocationGrowthCoordinator(
            census: dependencies.heapCensus,
            scheduler: dependencies.growthScheduler,
            publisher: broadcaster,
            logger: dependencies.logger
        )
        memoryReader = dependencies.memoryReader
        heapCensus = dependencies.heapCensus
        automaticTracking = dependencies.automaticTracking
        logger = dependencies.logger
        apply(configuration)
    }

    private static func makeLeakDetector(
        _ configuration: LeakDetectionConfiguration,
        _ dependencies: MemoryProfilerDependencies,
        _ publisher: any MemoryEventPublishing
    ) -> any LeakDetecting {
        LeakDetectionEngine(
            configuration: configuration,
            dependencies: LeakDetectionDependencies(
                deallocationObserver: dependencies.deallocationObserver,
                delayedExecutor: dependencies.delayedExecutor,
                inspector: dependencies.objectInspector,
                clock: dependencies.clock,
                publisher: publisher,
                referrerScanner: dependencies.referrerScanner
            )
        )
    }

    private static func makeMonitoring(
        _ dependencies: MemoryProfilerDependencies,
        _ publisher: any MemoryEventPublishing
    ) -> MemoryMonitoringCoordinator {
        MemoryMonitoringCoordinator(
            reader: dependencies.memoryReader,
            scheduler: dependencies.monitoringScheduler,
            pressureObserver: dependencies.pressureObserver,
            publisher: publisher,
            logger: dependencies.logger
        )
    }

    // MARK: - Lifecycle

    /// Pushes `configuration` to components that read it on every operation.
    func apply(_ configuration: MemoryProfilerConfiguration) {
        leakDetector.configure(configuration.leakDetection)
        diagnostics.updatePolicy(configuration.leakDetection.alertPolicy)
    }

    /// Starts monitoring, growth sampling and automatic tracking. Calls no client code.
    func start(with configuration: MemoryProfilerConfiguration) -> AllocationGrowthStartResult {
        monitoring.start(with: configuration.monitoring)
        let growth = allocationGrowth.start(with: configuration.allocationGrowth)
        if !configuration.leakDetection.automaticTracking.isEmpty {
            automaticTracking.attach(leakDetector, configuration: configuration.leakDetection)
        }
        return growth
    }

    /// Stops everything `start(with:)` started.
    func stop() {
        monitoring.stop()
        allocationGrowth.stop()
        automaticTracking.detach()
    }
}
