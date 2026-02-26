//
//  LeakDetecting.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

/// Expected lifetime behavior of a tracked object.
///
/// Determines how the leak detector decides whether an object
/// has survived past its intended lifecycle.
public enum ObjectLifetime: Sendable {

    /// The object should be deallocated when its owning scope ends.
    ///
    /// The detector checks after a configurable grace period
    /// (default 3 seconds) whether the object is still alive.
    case scopeBound

    /// The object should be deallocated within the specified duration.
    ///
    /// - Parameter seconds: Maximum expected lifetime in seconds.
    case timeBound(seconds: TimeInterval)
}

/// Detects potential memory leaks by tracking object lifecycles.
///
/// Implementations hold weak references to registered objects and
/// report any that survive past their expected lifetime as potential leaks.
public protocol LeakDetecting: AnyObject {

    /// Registers an object for leak tracking.
    ///
    /// - Parameters:
    ///   - object: The object to track (held weakly).
    ///   - expectedLifetime: How long the object is expected to live.
    func trackObject(
        _ object: AnyObject,
        expectedLifetime: ObjectLifetime
    )

    /// Checks all tracked objects and returns those that survived
    /// past their expected lifetime.
    ///
    /// - Returns: Information about each suspected leak.
    func checkForLeaks() -> [MemoryLeakInfo]

    /// Removes tracking for a specific object.
    ///
    /// - Parameter object: The object to stop tracking.
    /// - Returns: Whether the object was being tracked.
    @discardableResult
    func removeTracking(for object: AnyObject) -> Bool

    /// Removes entries for objects that have been deallocated.
    func purgeReleasedObjects()
}
