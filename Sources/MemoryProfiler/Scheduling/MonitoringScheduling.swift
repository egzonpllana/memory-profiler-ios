//
//  MonitoringScheduling.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

/// Manages periodic execution of monitoring tasks.
///
/// Implementations control the timing mechanism (Timer, GCD, etc.)
/// and expose lifecycle control for start/stop operations.
public protocol MonitoringScheduling: AnyObject {

    /// Starts executing the handler at the specified interval.
    ///
    /// - Parameters:
    ///   - interval: Time between executions in seconds.
    ///   - handler: The closure to execute on each tick.
    func start(interval: TimeInterval, handler: @escaping () -> Void)

    /// Stops the scheduled execution and releases resources.
    func stop()

    /// Whether the scheduler is currently running.
    var isActive: Bool { get }
}
