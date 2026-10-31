//
//  MemoryProfilerServicing.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Memory profiling and leak detection for iOS and macOS apps.
///
/// ```swift
/// let profiler = MemoryProfilerService.shared
/// profiler.start()                                 // footprint sampling + automatic UIKit tracking
/// profiler.expectDeallocation(of: viewModel)        // the scope that owned viewModel ended
/// for await event in profiler.events { ... }        // leaks, late releases, thresholds, pressure
/// ```
public protocol MemoryProfilerServicing: AnyObject, Sendable {

    /// Current lifecycle state.
    var state: MonitoringState { get }

    /// Active configuration.
    var configuration: MemoryProfilerConfiguration { get }

    /// A new stream of every event published from now on. Each access creates an independent stream.
    var events: AsyncStream<MemoryProfilerEvent> { get }

    /// Replaces the configuration. A running profiler restarts its components with the new values.
    func configure(_ configuration: MemoryProfilerConfiguration)

    /// Starts footprint sampling, memory pressure observation, automatic tracking and growth sampling.
    func start()

    /// Stops everything `start()` started. Manual expectations keep working.
    func stop()

    /// Re-enables a disabled profiler. Does not restart monitoring.
    func enable()

    /// Stops all activity and drops pending expectations until `enable()` is called.
    func disable()

    /// Registers a handler called on a private serial queue for every event.
    ///
    /// - Parameter handler: The event handler.
    /// - Returns: A subscription; call `cancel()` to unregister.
    @discardableResult
    func addEventHandler(_ handler: @escaping @Sendable (MemoryProfilerEvent) -> Void) -> EventSubscription

    /// Reads the current footprint. `nil` when the profiler is inactive or the kernel call fails.
    func currentStats() -> MemoryStats?

    /// Logs the current footprint with an optional context label.
    ///
    /// - Parameter context: Label appended to the log line; empty for none.
    func logMemoryUsage(context: String)

    /// Declares that `object` should deallocate within the grace period from now.
    ///
    /// If it is still alive at the deadline, `leakDetected` is published once. If it is released
    /// later, `leakResolved` follows. The object is held weakly.
    ///
    /// - Parameters:
    ///   - object: The object whose owning scope just ended.
    ///   - gracePeriod: Allowed lifetime from now; `nil` uses the configured grace period.
    ///   - reason: Why the object should deallocate.
    ///   - location: Source position reported with a leak.
    func expectDeallocation(
        of object: AnyObject,
        gracePeriod: Duration?,
        reason: DeallocationExpectationReason,
        location: SourceLocation
    )

    /// Counts `object` toward its type's live instance budget until it deallocates.
    ///
    /// Call it from the initializer. Exceeding the budget publishes `instanceBudgetExceeded` once
    /// until the count drops back within the budget.
    ///
    /// - Parameters:
    ///   - object: A newly created instance.
    ///   - budget: Maximum number of live instances of the type.
    ///   - location: Source position reported with a violation.
    func trackInstance(_ object: AnyObject, budget: Int, location: SourceLocation)

    /// Reports of objects that are currently leaked (detected and not yet released).
    func currentLeaks() -> [LeakReport]

    /// Counts live instances per class. Debug builds only.
    ///
    /// - Parameters:
    ///   - limit: Maximum number of entries, largest first.
    ///   - scope: Classes considered.
    /// - Returns: The census.
    /// - Throws: `HeapCensusError` when introspection is unavailable or the profiler is inactive.
    func heapCensus(limit: Int, scope: TypeScope) throws -> HeapCensus
}

// MARK: - Convenience

extension MemoryProfilerServicing {

    /// Declares that `object` should deallocate within the grace period from now.
    ///
    /// - Parameters:
    ///   - object: The object whose owning scope just ended.
    ///   - gracePeriod: Allowed lifetime from now; `nil` uses the configured grace period.
    public func expectDeallocation(
        of object: AnyObject,
        within gracePeriod: Duration? = nil,
        fileID: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) {
        let location = SourceLocation(fileID: fileID, line: line, function: function)
        expectDeallocation(of: object, gracePeriod: gracePeriod, reason: .manual, location: location)
    }

    /// Counts `object` toward its type's live instance budget until it deallocates.
    ///
    /// - Parameters:
    ///   - object: A newly created instance.
    ///   - budget: Maximum number of live instances of the type.
    public func trackInstance(
        _ object: AnyObject,
        budget: Int,
        fileID: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) {
        trackInstance(object, budget: budget, location: SourceLocation(fileID: fileID, line: line, function: function))
    }

    /// Logs the current footprint without a context label.
    public func logMemoryUsage() {
        logMemoryUsage(context: "")
    }

    /// The 25 largest application classes by bytes held. Debug builds only.
    public func heapCensus() throws -> HeapCensus {
        try heapCensus(limit: 25, scope: .applicationTypes)
    }
}
