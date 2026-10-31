//
//  DispatchRepeatingScheduler.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Repeating timer backed by a `DispatchSourceTimer` on a private serial queue.
///
/// Unlike `Timer`, it does not depend on the run loop of the calling thread, so it fires
/// no matter which thread starts it, and it can be stopped from any thread.
final class DispatchRepeatingScheduler: RepeatingScheduling {

    // MARK: - Properties

    private let queue: DispatchQueue
    private let timer = LockedState<(any DispatchSourceTimer)?>(nil)

    var isActive: Bool {
        timer.value != nil
    }

    // MARK: - Initialization

    init(label: String) {
        queue = DispatchQueue(label: label, qos: .utility)
    }

    deinit {
        timer.value?.cancel()
    }

    // MARK: - RepeatingScheduling

    func start(interval: Duration, handler: @escaping @Sendable () -> Void) {
        let newTimer = DispatchSource.makeTimerSource(queue: queue)
        let seconds = max(interval.timeInterval, 0.1)
        newTimer.schedule(deadline: .now(), repeating: seconds, leeway: .milliseconds(Int(seconds * 100)))
        newTimer.setEventHandler(handler: handler)
        let previous = timer.withLock { current -> (any DispatchSourceTimer)? in
            let replaced = current
            current = newTimer
            return replaced
        }
        previous?.cancel()
        newTimer.resume()
    }

    func stop() {
        let previous = timer.withLock { current -> (any DispatchSourceTimer)? in
            let replaced = current
            current = nil
            return replaced
        }
        previous?.cancel()
    }
}
