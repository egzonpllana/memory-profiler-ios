//
//  LeakAlertHandler.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Applies the leak alert policy to leak events.
struct LeakAlertHandler: Sendable {

    // MARK: - Properties

    let debuggerDetector: any DebuggerDetecting

    // MARK: - Public Methods

    /// Asserts or pauses in the debugger on the main thread when `event` signals a leak.
    func handle(_ event: MemoryProfilerEvent, message: String, policy: LeakAlertPolicy) {
        guard Self.isLeakSignal(event) else { return }
        switch policy {
        case .log:
            return
        case .assertionFailure:
            DispatchQueue.main.async {
                assertionFailure("MemoryProfiler: \(message)")
            }
        case .breakpoint:
            guard debuggerDetector.isDebuggerAttached else { return }
            DispatchQueue.main.async {
                // Paused here on purpose: open Debug Memory Graph and filter by the reported address.
                raise(SIGTRAP)
            }
        }
    }

    // MARK: - Private Methods

    private static func isLeakSignal(_ event: MemoryProfilerEvent) -> Bool {
        switch event {
        case .leakDetected, .instanceBudgetExceeded, .allocationGrowthDetected:
            return true
        case .leakResolved, .thresholdExceeded, .thresholdRecovered, .systemMemoryPressure:
            return false
        }
    }
}
