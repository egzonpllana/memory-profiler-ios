//
//  MemoryPressureObserving.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Observes system memory pressure.
protocol MemoryPressureObserving: Sendable {

    /// Starts delivering pressure changes to `handler` on a private queue. Replaces any previous handler.
    func startObserving(_ handler: @escaping @Sendable (MemoryPressureLevel) -> Void)

    /// Stops observation.
    func stopObserving()
}
