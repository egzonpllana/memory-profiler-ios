//
//  AllocationGrowthCoordinator.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Samples the heap periodically and publishes classes that keep accumulating instances.
final class AllocationGrowthCoordinator: Sendable {

    // MARK: - Properties

    private let census: any HeapCensusTaking
    private let scheduler: any RepeatingScheduling
    private let publisher: any MemoryEventPublishing
    private let logger: any MemoryLogging
    private let analyzer = LockedState<AllocationGrowthAnalyzer?>(nil)

    // MARK: - Initialization

    init(
        census: any HeapCensusTaking,
        scheduler: any RepeatingScheduling,
        publisher: any MemoryEventPublishing,
        logger: any MemoryLogging
    ) {
        self.census = census
        self.scheduler = scheduler
        self.publisher = publisher
        self.logger = logger
    }

    // MARK: - Lifecycle

    /// Starts sampling when `detection` is enabled and heap introspection is available.
    ///
    /// Never logs: it runs while the profiler holds its state lock, and a client logger that called
    /// back into the profiler would re-enter that lock.
    func start(with detection: AllocationGrowthDetection) -> AllocationGrowthStartResult {
        guard case .enabled(let policy) = detection else { return .disabled }
        guard census.isAvailable else { return .unavailable }
        analyzer.withLock { $0 = AllocationGrowthAnalyzer(policy: policy) }
        scheduler.start(interval: policy.sampleInterval) { [weak self] in
            self?.sample(scope: policy.scope)
        }
        return .started
    }

    /// Stops sampling and discards the history.
    func stop() {
        scheduler.stop()
        analyzer.withLock { $0 = nil }
    }

    // MARK: - Private Methods

    private func sample(scope: TypeScope) {
        let snapshot: HeapCensus
        do {
            snapshot = try census.takeCensus(scope: scope)
        } catch {
            logger.log("Heap census failed: \(error)", level: .warning, category: .heap)
            return
        }
        let suspects = analyzer.withLock { $0?.record(snapshot) ?? [] }
        for suspect in suspects {
            publisher.publish(.allocationGrowthDetected(suspect))
        }
    }
}
