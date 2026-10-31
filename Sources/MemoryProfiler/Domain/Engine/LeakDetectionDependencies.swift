//
//  LeakDetectionDependencies.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Collaborators of the leak detection engine.
struct LeakDetectionDependencies: Sendable {
    let deallocationObserver: any DeallocationObserving
    let delayedExecutor: any DelayedExecuting
    let inspector: any ObjectInspecting
    let clock: any TimeProviding
    let publisher: any MemoryEventPublishing
    let referrerScanner: any ReferrerScanning
}
