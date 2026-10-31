//
//  MemoryProfilerService.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// The memory profiler.
///
/// Use `MemoryProfilerService.shared`, or create an instance for dependency injection.
/// All methods are thread-safe.
public final class MemoryProfilerService: MemoryProfilerServicing {

    // MARK: - Properties

    /// The process-wide profiler used by `DeinitTracker`, `detectLeaks(of:)` and the Objective-C bridge.
    public static let shared = MemoryProfilerService()

    let components: ProfilerComponents
    let serviceState: LockedState<ServiceState>

    /// Serializes start, stop, enable, disable and configure so state and components never diverge.
    /// Client code (the logger) is never called while it is held, so a logger may call back in.
    private let transitionLock = LockedState(())

    public var state: MonitoringState {
        serviceState.value.status
    }

    public var configuration: MemoryProfilerConfiguration {
        serviceState.value.configuration
    }

    var isActive: Bool {
        serviceState.value.isActive
    }

    // MARK: - Initialization

    /// Creates a profiler.
    ///
    /// - Parameters:
    ///   - configuration: Profiler configuration. Defaults to `.default`.
    ///   - logger: Log destination. Defaults to the unified logging system.
    public convenience init(
        configuration: MemoryProfilerConfiguration = .default,
        logger: any MemoryLogging = OSLogMemoryLogger()
    ) {
        self.init(configuration: configuration, dependencies: .live(logger: logger))
    }

    init(configuration: MemoryProfilerConfiguration, dependencies: MemoryProfilerDependencies) {
        components = ProfilerComponents(configuration: configuration, dependencies: dependencies)
        serviceState = LockedState(ServiceState(status: .idle, configuration: configuration))
    }

    // MARK: - Lifecycle

    public func configure(_ configuration: MemoryProfilerConfiguration) {
        let growth = transitionLock.withLock { _ -> AllocationGrowthStartResult in
            let status = serviceState.withLock { state -> MonitoringState in
                state.configuration = configuration
                return state.status
            }
            components.apply(configuration)
            guard status == .monitoring else { return .disabled }
            components.stop()
            guard configuration.environment.isActiveInCurrentBuild else {
                serviceState.withLock { $0.status = .idle }
                return .disabled
            }
            return components.start(with: configuration)
        }
        log("Configuration updated.")
        logGrowthAvailability(growth)
    }

    public func start() {
        let growth = transitionLock.withLock { _ -> AllocationGrowthStartResult? in
            let current = serviceState.value
            guard current.status == .idle,
                  current.configuration.environment.isActiveInCurrentBuild else { return nil }
            let growth = components.start(with: current.configuration)
            serviceState.withLock { $0.status = .monitoring }
            return growth
        }
        guard let growth else { return }
        log("Started monitoring.")
        logGrowthAvailability(growth)
    }

    public func stop() {
        let stopped = transitionLock.withLock { _ -> Bool in
            guard serviceState.value.status == .monitoring else { return false }
            components.stop()
            serviceState.withLock { $0.status = .idle }
            return true
        }
        if stopped {
            log("Stopped monitoring.")
        }
    }

    public func enable() {
        let enabled = transitionLock.withLock { _ -> Bool in
            serviceState.withLock { state -> Bool in
                guard state.status == .disabled else { return false }
                state.status = .idle
                return true
            }
        }
        if enabled {
            log("Enabled.")
        }
    }

    public func disable() {
        let disabled = transitionLock.withLock { _ -> Bool in
            let status = serviceState.value.status
            guard status != .disabled else { return false }
            if status == .monitoring {
                components.stop()
            }
            components.leakDetector.reset()
            serviceState.withLock { $0.status = .disabled }
            return true
        }
        if disabled {
            log("Disabled.")
        }
    }

    // MARK: - Private Methods

    private func log(_ message: String) {
        components.logger.log(message, level: .info, category: .lifecycle)
    }

    private func logGrowthAvailability(_ result: AllocationGrowthStartResult) {
        guard result == .unavailable else { return }
        components.logger.log(
            "Allocation growth detection is unavailable: heap introspection is compiled into debug builds only.",
            level: .warning,
            category: .heap
        )
    }
}
