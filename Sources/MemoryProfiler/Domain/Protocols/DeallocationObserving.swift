//
//  DeallocationObserving.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Notifies when an object deallocates.
protocol DeallocationObserving: Sendable {

    /// Whether deallocation of `object` can be observed. Actors forbid the associated objects
    /// the observation relies on.
    func canObserveDeallocation(of object: AnyObject) -> Bool

    /// Calls `handler` once, on the deallocating thread, when `object` deallocates.
    /// Does nothing when `canObserveDeallocation(of:)` is `false`. The handler must not touch the object.
    func observeDeallocation(of object: AnyObject, _ handler: @escaping @Sendable () -> Void)
}
