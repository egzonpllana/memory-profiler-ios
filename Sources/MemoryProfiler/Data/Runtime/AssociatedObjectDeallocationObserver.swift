//
//  AssociatedObjectDeallocationObserver.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Distributed
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

    /// Swift actors and distributed actors abort the process when given an associated object.
    func canObserveDeallocation(of object: AnyObject) -> Bool {
        !(object is any Actor) && !(object is any DistributedActor)
    }

    func observeDeallocation(of object: AnyObject, _ handler: @escaping @Sendable () -> Void) {
        guard canObserveDeallocation(of: object) else { return }
        let sentinel = Self.attachmentLock.withLock { _ in Self.sentinel(for: object) }
        sentinel.append(handler)
    }

    // MARK: - Private Methods

    /// The pool keeps an existing sentinel from outliving its host through autorelease.
    private static func sentinel(for object: AnyObject) -> DeallocationSentinel {
        let existing = autoreleasepool {
            objc_getAssociatedObject(object, &associationKey) as? DeallocationSentinel
        }
        if let existing {
            return existing
        }
        let sentinel = DeallocationSentinel()
        objc_setAssociatedObject(object, &associationKey, sentinel, .OBJC_ASSOCIATION_RETAIN)
        return sentinel
    }
}
