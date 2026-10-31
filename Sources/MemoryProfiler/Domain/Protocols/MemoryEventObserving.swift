//
//  MemoryEventObserving.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Internal consumer of every published event, such as logging and alerting.
protocol MemoryEventObserving: Sendable {

    /// Handles `event` on the broadcaster queue.
    func observe(_ event: MemoryProfilerEvent)
}
