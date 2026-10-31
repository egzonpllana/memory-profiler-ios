//
//  EventSubscription.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Registration of an event handler. Call `cancel()` to stop receiving events.
///
/// Releasing the subscription does not cancel it, so handlers meant to live as long as
/// the app can ignore the returned value.
public final class EventSubscription: Sendable {

    // MARK: - Properties

    private let cancellation: LockedState<(@Sendable () -> Void)?>

    // MARK: - Initialization

    init(cancellation: @escaping @Sendable () -> Void) {
        self.cancellation = LockedState(cancellation)
    }

    // MARK: - Public Methods

    /// Stops delivering events to the handler. Safe to call more than once.
    public func cancel() {
        let action = cancellation.withLock { stored -> (@Sendable () -> Void)? in
            let current = stored
            stored = nil
            return current
        }
        action?()
    }
}
