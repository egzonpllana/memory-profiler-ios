//
//  DeallocationExpectationStore.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Thread-safe registry of deallocation expectations.
///
/// Keys are disguised addresses so the registry never holds a raw pointer to a tracked object.
/// No weak reference is ever loaded under the lock: a temporary strong reference released there
/// could run a `deinit` that calls back into the store and re-enters the lock.
final class DeallocationExpectationStore: Sendable {

    // MARK: - Types

    private struct Registry {
        var nextToken: UInt64 = 1
        var entries: [UInt64: DeallocationExpectation] = [:]
        var tokensByAddress: [DisguisedAddress: UInt64] = [:]
    }

    // MARK: - Properties

    private let registry = LockedState(Registry())

    // MARK: - Registration

    /// Whether an object at `address` already has an expectation.
    ///
    /// Two live objects never share an address, and a sentinel-observed expectation is removed
    /// before its object's memory is freed, so an existing entry means the same object.
    func isTracking(_ address: DisguisedAddress) -> Bool {
        registry.withLock { $0.tokensByAddress[address] != nil }
    }

    /// Registers the expectation built by `make` unless the address is already tracked.
    ///
    /// - Returns: The new token, or `nil` for a duplicate.
    func register(at address: DisguisedAddress, make: (UInt64) -> DeallocationExpectation) -> UInt64? {
        registry.withLock { registry in
            guard registry.tokensByAddress[address] == nil else { return nil }
            let token = registry.nextToken
            registry.nextToken += 1
            registry.entries[token] = make(token)
            registry.tokensByAddress[address] = token
            return token
        }
    }

    // MARK: - Queries

    /// The expectation for `token` while it is still pending.
    func pendingExpectation(for token: UInt64) -> DeallocationExpectation? {
        registry.withLock { registry in
            guard let entry = registry.entries[token], case .pending = entry.phase else { return nil }
            return entry
        }
    }

    /// Reports of objects that are currently leaked.
    func leakedReports() -> [LeakReport] {
        registry.withLock { registry in
            registry.entries.values.compactMap { entry in
                guard case .leaked(let report) = entry.phase else { return nil }
                return report
            }
        }
    }

    /// Heap addresses of the weak boxes, excluded from referrer scans.
    func boxAddresses() -> [UInt] {
        registry.withLock { $0.entries.values.flatMap(\.boxAddresses) }
    }

    // MARK: - Mutations

    /// Moves a pending expectation to `phase`. Returns `false` when it is no longer pending.
    func advance(_ token: UInt64, to phase: ExpectationPhase) -> Bool {
        registry.withLock { registry in
            guard var entry = registry.entries[token], case .pending = entry.phase else { return false }
            entry.phase = phase
            registry.entries[token] = entry
            return true
        }
    }

    /// Finishes retention analysis and marks the entry leaked.
    ///
    /// - Returns: The completed report, or `nil` when the object was released during the analysis.
    func completeAnalysis(_ token: UInt64, retention: RetentionAnalysis?) -> LeakReport? {
        registry.withLock { registry in
            guard var entry = registry.entries[token], case .analyzing(let report) = entry.phase else { return nil }
            let completed = report.withRetention(retention)
            entry.phase = .leaked(completed)
            registry.entries[token] = entry
            return completed
        }
    }

    /// Removes and returns the expectation for `token`.
    @discardableResult
    func remove(_ token: UInt64) -> DeallocationExpectation? {
        registry.withLock { registry in
            guard let entry = registry.entries.removeValue(forKey: token) else { return nil }
            if registry.tokensByAddress[entry.address] == token {
                registry.tokensByAddress[entry.address] = nil
            }
            return entry
        }
    }

    /// Removes every expectation. The entries are released after the lock is dropped.
    func removeAll() {
        let removed = registry.withLock { registry -> [UInt64: DeallocationExpectation] in
            let entries = registry.entries
            registry.entries.removeAll()
            registry.tokensByAddress.removeAll()
            return entries
        }
        _ = removed
    }
}
