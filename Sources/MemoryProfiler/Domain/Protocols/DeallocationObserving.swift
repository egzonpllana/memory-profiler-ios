//
//  DeallocationObserving.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Notifies when an object deallocates.
protocol DeallocationObserving: Sendable {

    /// Calls `handler` once, on the deallocating thread, when `object` deallocates.
    /// The handler must not touch the object.
    func observeDeallocation(of object: AnyObject, _ handler: @escaping @Sendable () -> Void)
}
