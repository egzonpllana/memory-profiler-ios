//
//  RepeatingScheduling.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Runs a handler periodically on a private queue.
protocol RepeatingScheduling: Sendable {

    /// Whether a schedule is active.
    var isActive: Bool { get }

    /// Starts a schedule that fires immediately and then every `interval`. Replaces any previous schedule.
    /// Never calls `handler` synchronously.
    func start(interval: Duration, handler: @escaping @Sendable () -> Void)

    /// Cancels the schedule.
    func stop()
}
