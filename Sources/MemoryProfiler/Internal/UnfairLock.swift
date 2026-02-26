//
//  UnfairLock.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation
import os

/// A lightweight mutual exclusion lock backed by `os_unfair_lock`.
///
/// Provides thread-safe access to shared mutable state without
/// the overhead of `NSLock` or Dispatch queues. Must not be
/// held across suspension points (not compatible with Swift concurrency await).
final class UnfairLock: @unchecked Sendable {

    // MARK: - Properties

    private let lockPointer: UnsafeMutablePointer<os_unfair_lock>

    // MARK: - Initialization

    /// Creates a new unfair lock.
    init() {
        lockPointer = .allocate(capacity: 1)
        lockPointer.initialize(to: os_unfair_lock())
    }

    deinit {
        lockPointer.deinitialize(count: 1)
        lockPointer.deallocate()
    }

    // MARK: - Locking

    /// Executes the given closure while holding the lock.
    ///
    /// - Parameter body: The closure to execute under mutual exclusion.
    /// - Returns: The value returned by `body`.
    func withLock<Result>(_ body: () throws -> Result) rethrows -> Result {
        os_unfair_lock_lock(lockPointer)
        defer { os_unfair_lock_unlock(lockPointer) }
        return try body()
    }
}
