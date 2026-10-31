//
//  MemoryMonitoringCoordinator.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Periodic footprint sampling, threshold transitions and system memory pressure.
final class MemoryMonitoringCoordinator: Sendable {

    // MARK: - Types

    private struct Session {
        var threshold: MemoryThreshold
        var evaluator = ThresholdEvaluator()
    }

    // MARK: - Properties

    private let reader: any MemoryReading
    private let scheduler: any RepeatingScheduling
    private let pressureObserver: any MemoryPressureObserving
    private let publisher: any MemoryEventPublishing
    private let logger: any MemoryLogging
    private let session = LockedState(Session(threshold: .fractionOfLimit(0.8)))

    // MARK: - Initialization

    init(
        reader: any MemoryReading,
        scheduler: any RepeatingScheduling,
        pressureObserver: any MemoryPressureObserving,
        publisher: any MemoryEventPublishing,
        logger: any MemoryLogging
    ) {
        self.reader = reader
        self.scheduler = scheduler
        self.pressureObserver = pressureObserver
        self.publisher = publisher
        self.logger = logger
    }

    // MARK: - Lifecycle

    /// Starts sampling with `configuration`. The first sample is taken immediately.
    func start(with configuration: MonitoringConfiguration) {
        session.withLock { $0 = Session(threshold: configuration.warningThreshold) }
        scheduler.start(interval: configuration.interval) { [weak self] in
            self?.sampleFootprint()
        }
        guard configuration.observesSystemMemoryPressure else { return }
        pressureObserver.startObserving { [publisher] level in
            publisher.publish(.systemMemoryPressure(level))
        }
    }

    /// Stops sampling and pressure observation.
    func stop() {
        scheduler.stop()
        pressureObserver.stopObserving()
    }

    // MARK: - Private Methods

    private func sampleFootprint() {
        guard let stats = reader.readStats() else {
            logger.log("Footprint could not be read from the kernel.", level: .warning, category: .monitoring)
            return
        }
        logger.log("Footprint sample: \(stats)", level: .debug, category: .monitoring)
        let transition = session.withLock { $0.evaluator.evaluate(stats, threshold: $0.threshold) }
        switch transition {
        case .exceeded:
            publisher.publish(.thresholdExceeded(stats))
        case .recovered:
            publisher.publish(.thresholdRecovered(stats))
        case nil:
            return
        }
    }
}
