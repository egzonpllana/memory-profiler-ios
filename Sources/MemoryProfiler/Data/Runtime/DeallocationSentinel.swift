//
//  DeallocationSentinel.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Associated object whose deinit runs when its host object deallocates.
///
/// The Objective-C runtime releases associated objects while destroying the host, for
/// `NSObject` subclasses and native Swift classes alike.
final class DeallocationSentinel: Sendable {

    // MARK: - Properties

    private let handlers = LockedState<[@Sendable () -> Void]>([])

    // MARK: - Initialization

    deinit {
        let pending = handlers.withLock { stored -> [@Sendable () -> Void] in
            let current = stored
            stored = []
            return current
        }
        for handler in pending {
            handler()
        }
    }

    // MARK: - Public Methods

    /// Adds a handler that runs when the host deallocates.
    func append(_ handler: @escaping @Sendable () -> Void) {
        handlers.withLock { $0.append(handler) }
    }
}
