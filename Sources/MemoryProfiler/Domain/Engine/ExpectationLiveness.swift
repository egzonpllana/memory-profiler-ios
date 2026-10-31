//
//  ExpectationLiveness.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// How the engine learns that an expected object is gone.
enum ExpectationLiveness: Sendable {

    /// A deallocation sentinel removes the expectation when the object deallocates.
    /// No reference to the object is held, so objects in the middle of `deinit` are safe to pass.
    case observedBySentinel

    /// Actors cannot carry associated objects, so a weak reference is checked at the deadline instead.
    /// Native Swift weak references never trap, even for an actor that is deinitializing.
    case weakReference(WeakObjectBox)

    /// Whether the object can still be alive. Loads the weak reference; call on the main thread.
    var mayBeAlive: Bool {
        switch self {
        case .observedBySentinel:
            return true
        case .weakReference(let box):
            return box.object != nil
        }
    }

    /// The weak box, if any, so its address can be excluded from referrer scans.
    var box: WeakObjectBox? {
        switch self {
        case .observedBySentinel:
            return nil
        case .weakReference(let box):
            return box
        }
    }
}
