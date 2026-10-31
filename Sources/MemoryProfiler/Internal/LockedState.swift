//
//  LockedState.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import os

/// Mutable state guarded by an `OSAllocatedUnfairLock`.
///
/// `@unchecked Sendable` is sound because every read and write of `State` goes through the lock.
/// Never call client code, block, or take another `LockedState` of the same owner while holding it.
struct LockedState<State>: @unchecked Sendable {

    // MARK: - Properties

    private let lock: OSAllocatedUnfairLock<State>

    // MARK: - Initialization

    init(_ initialState: State) {
        lock = OSAllocatedUnfairLock(uncheckedState: initialState)
    }

    // MARK: - Access

    /// A copy of the current state.
    var value: State {
        lock.withLockUnchecked { $0 }
    }

    /// Runs `body` with exclusive access to the state.
    func withLock<Result>(_ body: (inout State) throws -> Result) rethrows -> Result {
        try lock.withLockUnchecked(body)
    }
}
