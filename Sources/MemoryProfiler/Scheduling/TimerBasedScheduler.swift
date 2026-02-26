//
//  TimerBasedScheduler.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

/// Scheduler backed by `Timer.scheduledTimer` on the main run loop.
///
/// Suitable for low-frequency periodic tasks like memory checks.
/// The timer fires on `RunLoop.main` — handlers must not block.
/// All state mutations are protected by `UnfairLock`.
public final class TimerBasedScheduler: MonitoringScheduling {

    // MARK: - Properties

    private let lock = UnfairLock()
    private var timer: Timer?

    /// Whether the scheduler is currently running.
    public var isActive: Bool { lock.withLock { timer != nil } }

    // MARK: - Initialization

    /// Creates a timer-based scheduler.
    public init() {}

    deinit {
        timer?.invalidate()
    }

    // MARK: - MonitoringScheduling

    public func start(
        interval: TimeInterval,
        handler: @escaping () -> Void
    ) {
        lock.withLock {
            timer?.invalidate()
            timer = Timer.scheduledTimer(
                withTimeInterval: interval,
                repeats: true
            ) { _ in
                handler()
            }
        }
    }

    public func stop() {
        lock.withLock {
            timer?.invalidate()
            timer = nil
        }
    }
}
