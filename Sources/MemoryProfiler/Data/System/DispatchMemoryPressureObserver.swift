//
//  DispatchMemoryPressureObserver.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Observes system memory pressure with a dispatch memory pressure source.
final class DispatchMemoryPressureObserver: MemoryPressureObserving {

    // MARK: - Properties

    private let queue = DispatchQueue(label: "com.egzonpllana.MemoryProfiler.pressure", qos: .utility)
    private let source = LockedState<(any DispatchSourceMemoryPressure)?>(nil)

    // MARK: - Initialization

    deinit {
        source.value?.cancel()
    }

    // MARK: - MemoryPressureObserving

    func startObserving(_ handler: @escaping @Sendable (MemoryPressureLevel) -> Void) {
        let newSource = DispatchSource.makeMemoryPressureSource(eventMask: [.normal, .warning, .critical], queue: queue)
        let reference = LockedState<(any DispatchSourceMemoryPressure)?>(newSource)
        newSource.setEventHandler {
            guard let event = reference.value?.data else { return }
            handler(Self.level(for: event))
        }
        newSource.setCancelHandler {
            reference.withLock { $0 = nil }
        }
        let previous = source.withLock { current -> (any DispatchSourceMemoryPressure)? in
            let replaced = current
            current = newSource
            return replaced
        }
        previous?.cancel()
        newSource.resume()
    }

    func stopObserving() {
        let previous = source.withLock { current -> (any DispatchSourceMemoryPressure)? in
            let replaced = current
            current = nil
            return replaced
        }
        previous?.cancel()
    }

    // MARK: - Private Methods

    private static func level(for event: DispatchSource.MemoryPressureEvent) -> MemoryPressureLevel {
        if event.contains(.critical) {
            return .critical
        }
        return event.contains(.warning) ? .warning : .normal
    }
}
