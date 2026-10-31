//
//  ManualDelayedExecutor.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

/// Holds delayed work until the test runs it on the current (main) thread.
final class ManualDelayedExecutor: DelayedExecuting, @unchecked Sendable {

    struct ScheduledWork {
        let delay: Duration
        let work: @Sendable () -> Void
    }

    private let scheduled = LockedState<[ScheduledWork]>([])

    var pendingCount: Int {
        scheduled.value.count
    }

    var delays: [Duration] {
        scheduled.value.map(\.delay)
    }

    func executeOnMain(after delay: Duration, _ work: @escaping @Sendable () -> Void) {
        scheduled.withLock { $0.append(ScheduledWork(delay: delay, work: work)) }
    }

    func runAll() {
        let pending = scheduled.withLock { stored -> [ScheduledWork] in
            let current = stored
            stored = []
            return current
        }
        for item in pending {
            item.work()
        }
    }
}
