//
//  MemoryProfilerService.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.7.25.
//

import Foundation

/// Production-grade memory profiling service.
///
/// Thin facade that coordinates monitoring, leak detection, scheduling,
/// and logging through injected components. All mutable state is
/// protected by `UnfairLock` for thread safety.
public final class MemoryProfilerService: MemoryProfilerServicing, @unchecked Sendable {

    // MARK: - Properties

    private let monitor: MemoryMonitoring
    private let scheduler: MonitoringScheduling
    private let leakDetector: LeakDetecting
    private let logger: MemoryLogging
    private let lock = UnfairLock()

    private var state: MonitoringState
    private var memoryWarningThreshold: UInt64 = 0
    private var peakMemoryUsage: UInt64 = 0

    /// The environment configuration for the service.
    public let environment: MemoryProfilerEnvironment

    // MARK: - Initialization

    /// Creates a memory profiler service with default components.
    ///
    /// Sets the warning threshold to 70% of device RAM.
    ///
    /// - Parameters:
    ///   - isEnabled: Whether the service starts enabled. Default is true.
    ///   - environment: Build environment gating. Default is `.debugOnly`.
    ///   - monitor: Memory reader. Default is `SystemMemoryMonitor`.
    ///   - scheduler: Periodic timer. Default is `TimerBasedScheduler`.
    ///   - leakDetector: Leak tracker. Default is `WeakReferenceTracker`.
    ///   - logger: Log output. Default is `ConsoleMemoryLogger`.
    public init(
        isEnabled: Bool = true,
        environment: MemoryProfilerEnvironment = .debugOnly,
        monitor: MemoryMonitoring = SystemMemoryMonitor(),
        scheduler: MonitoringScheduling = TimerBasedScheduler(),
        leakDetector: LeakDetecting = WeakReferenceTracker(),
        logger: MemoryLogging = ConsoleMemoryLogger()
    ) {
        self.environment = environment
        self.state = isEnabled ? .idle : .disabled
        self.monitor = monitor
        self.scheduler = scheduler
        self.leakDetector = leakDetector
        self.logger = logger
        configureDefaultThreshold()
    }
}

// MARK: - MemoryProfilerServicing

extension MemoryProfilerService {

    public func startMonitoring() {
        guard shouldRun() else { return }
        let alreadyMonitoring = lock.withLock {
            guard state == .idle else { return true }
            state = .monitoring
            return false
        }
        guard !alreadyMonitoring else { return }
        logger.log("Started monitoring")
        scheduler.start(interval: 60.0) { [weak self] in
            self?.performMemoryCheck()
        }
    }

    public func stopMonitoring() {
        guard shouldRun() else { return }
        let wasMonitoring = lock.withLock {
            guard state == .monitoring else { return false }
            state = .idle
            return true
        }
        guard wasMonitoring else { return }
        scheduler.stop()
        logger.log("Stopped monitoring")
    }

    public func getMemoryStats() -> MemoryStats {
        guard shouldRun() else {
            return MemoryStats(
                usedMemory: 0,
                availableMemory: 0,
                totalMemory: 0,
                peakMemoryUsage: 0
            )
        }
        return buildCurrentStats()
    }

    public func detectMemoryLeaks() -> [MemoryLeakInfo] {
        guard shouldRun() else { return [] }
        return leakDetector.checkForLeaks()
    }

    public func logMemoryUsage(context: String) {
        guard shouldRun() else { return }
        logFormattedStats(context: context)
    }

    public func setMemoryWarningThreshold(_ threshold: UInt64) {
        guard shouldRun() else { return }
        lock.withLock { memoryWarningThreshold = threshold }
        logger.log("Threshold set to \(threshold / 1024 / 1024)MB")
    }

    public func trackObject(
        _ object: AnyObject,
        expectedLifetime: ObjectLifetime
    ) {
        guard shouldRun() else { return }
        leakDetector.trackObject(object, expectedLifetime: expectedLifetime)
    }

    @discardableResult
    public func removeTracking(for object: AnyObject) -> Bool {
        guard shouldRun() else { return false }
        return leakDetector.removeTracking(for: object)
    }

    /// Enables the memory profiler service.
    ///
    /// Transitions the service from disabled to idle state.
    /// Does not automatically restart monitoring.
    public func enable() {
        lock.withLock {
            if state == .disabled { state = .idle }
        }
        logger.log("Enabled")
    }

    /// Disables the memory profiler service.
    ///
    /// Stops all monitoring activities and transitions to disabled state.
    /// The service will not perform any operations until re-enabled.
    public func disable() {
        let wasMonitoring = lock.withLock {
            let monitoring = state == .monitoring
            state = .disabled
            return monitoring
        }
        if wasMonitoring { scheduler.stop() }
        logger.log("Disabled")
    }

    /// Whether the service is currently enabled.
    public var isServiceEnabled: Bool {
        lock.withLock { state != .disabled }
    }
}

// MARK: - Private Methods

extension MemoryProfilerService {

    private func shouldRun() -> Bool {
        let currentState = lock.withLock { state }
        guard currentState != .disabled else { return false }
        switch environment {
        case .debugOnly:
            #if DEBUG
            return true
            #else
            return false
            #endif
        case .all:
            return true
        }
    }

    private func configureDefaultThreshold() {
        let total = monitor.totalMemory()
        memoryWarningThreshold = UInt64(Double(total) * 0.7)
        let thresholdMB = memoryWarningThreshold / 1024 / 1024
        let totalMB = total / 1024 / 1024
        logger.log(
            "Threshold set to \(thresholdMB)MB"
            + " (70% of \(totalMB)MB total)"
        )
    }

    private func buildCurrentStats() -> MemoryStats {
        let used = monitor.currentMemoryUsage()
        let total = monitor.totalMemory()
        let available = total > used ? total - used : 0
        let peak = lock.withLock {
            if used > peakMemoryUsage { peakMemoryUsage = used }
            return peakMemoryUsage
        }
        return MemoryStats(
            usedMemory: used,
            availableMemory: available,
            totalMemory: total,
            peakMemoryUsage: peak
        )
    }

    private func logFormattedStats(context: String) {
        let stats = getMemoryStats()
        let suffix = context.isEmpty ? "" : " [\(context)]"
        let pct = String(format: "%.2f", stats.memoryUsagePercentage)
        let usedMB = stats.usedMemory / 1024 / 1024
        let availMB = stats.availableMemory / 1024 / 1024
        let totalMB = stats.totalMemory / 1024 / 1024
        logger.log(
            "Memory: \(pct)% (used: \(usedMB)MB,"
            + " available: \(availMB)MB,"
            + " total: \(totalMB)MB)\(suffix)"
        )
    }

    private func performMemoryCheck() {
        let stats = getMemoryStats()
        let usedMB = stats.usedMemory / 1024 / 1024
        let threshold = lock.withLock { memoryWarningThreshold }
        if stats.usedMemory > threshold {
            let thresholdMB = threshold / 1024 / 1024
            logger.logWarning(
                "Memory exceeded threshold:"
                + " \(usedMB)MB > \(thresholdMB)MB"
            )
        } else {
            logger.log("Periodic check: \(usedMB)MB used")
        }
        leakDetector.purgeReleasedObjects()
    }
}
