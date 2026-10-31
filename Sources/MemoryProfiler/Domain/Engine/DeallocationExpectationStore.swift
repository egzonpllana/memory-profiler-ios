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

    /// Whether `object` already has a live expectation.
    func isTracking(_ object: AnyObject, at address: DisguisedAddress) -> Bool {
        registry.withLock { Self.liveToken(for: object, at: address, in: $0) != nil }
    }

    /// Registers the expectation built by `make` unless `object` is already tracked.
    ///
    /// - Returns: The new token, or `nil` for a duplicate.
    func register(
        _ object: AnyObject,
        at address: DisguisedAddress,
        make: (UInt64) -> DeallocationExpectation
    ) -> UInt64? {
        registry.withLock { registry in
            guard Self.liveToken(for: object, at: address, in: registry) == nil else { return nil }
            if let staleToken = registry.tokensByAddress[address] {
                registry.entries[staleToken] = nil
            }
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
        registry.withLock { $0.entries.values.map(\.box.address) }
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

    /// Removes every expectation.
    func removeAll() {
        registry.withLock { registry in
            registry.entries.removeAll()
            registry.tokensByAddress.removeAll()
        }
    }

    // MARK: - Private Methods

    private static func liveToken(
        for object: AnyObject,
        at address: DisguisedAddress,
        in registry: Registry
    ) -> UInt64? {
        guard let token = registry.tokensByAddress[address],
              let entry = registry.entries[token],
              entry.box.object === object else { return nil }
        return token
    }
}
