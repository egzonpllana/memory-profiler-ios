//
//  MemoryProfilerServicing.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.7.25.
//

import Foundation

/// Environment configuration for the memory profiler service.
///
/// Determines when the memory profiler service should be active:
/// - `.debugOnly`: Only runs in debug builds.
/// - `.all`: Runs in all builds (debug and release).
public enum MemoryProfilerEnvironment: Sendable {
    /// Only runs in debug builds.
    case debugOnly
    /// Runs in all builds (debug and release).
    case all
}

/// A production-grade memory profiling service for iOS and macOS applications.
///
/// Provides real-time memory monitoring, lifecycle-based leak detection,
/// and configurable threshold warnings using system-level APIs.
///
/// ## Usage
///
/// ```swift
/// let profiler = MemoryProfilerService()
/// profiler.startMonitoring()
///
/// // Track objects for leak detection
/// profiler.trackObject(viewModel, expectedLifetime: .scopeBound)
///
/// // Log memory at key points
/// profiler.logMemoryUsage(context: "Data loading")
///
/// // Check for leaks
/// let leaks = profiler.detectMemoryLeaks()
/// ```
public protocol MemoryProfilerServicing: AnyObject {

    /// Starts periodic memory monitoring.
    func startMonitoring()

    /// Stops monitoring and releases scheduler resources.
    func stopMonitoring()

    /// Returns current memory statistics.
    ///
    /// - Returns: A snapshot of current memory usage.
    func getMemoryStats() -> MemoryStats

    /// Checks all tracked objects for potential leaks.
    ///
    /// - Returns: Information about each suspected leak.
    func detectMemoryLeaks() -> [MemoryLeakInfo]

    /// Logs current memory usage to the configured logger.
    ///
    /// - Parameter context: Optional label for the log entry.
    func logMemoryUsage(context: String)

    /// Sets the memory warning threshold in bytes.
    ///
    /// - Parameter threshold: Memory threshold in bytes.
    func setMemoryWarningThreshold(_ threshold: UInt64)

    /// Registers an object for lifecycle-based leak tracking.
    ///
    /// - Parameters:
    ///   - object: The object to track (held weakly).
    ///   - expectedLifetime: How long the object is expected to live.
    func trackObject(
        _ object: AnyObject,
        expectedLifetime: ObjectLifetime
    )

    /// Removes leak tracking for a specific object.
    ///
    /// - Parameter object: The object to stop tracking.
    /// - Returns: Whether the object was being tracked.
    @discardableResult
    func removeTracking(for object: AnyObject) -> Bool

    /// Enables the memory profiler service.
    func enable()

    /// Disables the memory profiler service and stops all activities.
    func disable()

    /// Whether the service is currently enabled.
    var isServiceEnabled: Bool { get }

    /// The configured environment for the service.
    var environment: MemoryProfilerEnvironment { get }
}

// MARK: - Convenience

extension MemoryProfilerServicing {

    /// Logs current memory usage without additional context.
    public func logMemoryUsage() {
        logMemoryUsage(context: "")
    }
}
