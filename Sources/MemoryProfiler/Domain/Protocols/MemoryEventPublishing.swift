//
//  MemoryEventPublishing.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Publishes profiler events to subscribers.
protocol MemoryEventPublishing: Sendable {

    /// Publishes `event` asynchronously. Never calls subscribers synchronously.
    func publish(_ event: MemoryProfilerEvent)
}
