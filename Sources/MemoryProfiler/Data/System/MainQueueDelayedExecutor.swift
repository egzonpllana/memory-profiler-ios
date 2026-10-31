//
//  MainQueueDelayedExecutor.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Runs delayed work on the main queue.
struct MainQueueDelayedExecutor: DelayedExecuting {

    // MARK: - DelayedExecuting

    func executeOnMain(after delay: Duration, _ work: @escaping @Sendable () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay.dispatchInterval, execute: work)
    }
}
