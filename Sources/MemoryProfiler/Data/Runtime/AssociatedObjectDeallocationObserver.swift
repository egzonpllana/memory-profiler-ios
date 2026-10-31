//
//  AssociatedObjectDeallocationObserver.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
import ObjectiveC

/// Observes deallocation by attaching a `DeallocationSentinel` as an associated object.
struct AssociatedObjectDeallocationObserver: DeallocationObserving {

    // MARK: - Properties

    /// Only the address is used, as the association key.
    nonisolated(unsafe) private static var associationKey: UInt8 = 0

    /// Serializes get-or-create so concurrent observers of one object share one sentinel.
    private static let attachmentLock = LockedState(())

    // MARK: - DeallocationObserving

    func observeDeallocation(of object: AnyObject, _ handler: @escaping @Sendable () -> Void) {
        let sentinel = Self.attachmentLock.withLock { _ in Self.sentinel(for: object) }
        sentinel.append(handler)
    }

    // MARK: - Private Methods

    private static func sentinel(for object: AnyObject) -> DeallocationSentinel {
        if let existing = objc_getAssociatedObject(object, &associationKey) as? DeallocationSentinel {
            return existing
        }
        let sentinel = DeallocationSentinel()
        objc_setAssociatedObject(object, &associationKey, sentinel, .OBJC_ASSOCIATION_RETAIN)
        return sentinel
    }
}
