//
//  InstanceBudgetRegistry.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Live instance counts per type for `trackInstance` budgets.
final class InstanceBudgetRegistry: Sendable {

    // MARK: - Types

    private enum BudgetState {
        case withinBudget
        case exceeded
    }

    private struct TypeBudget {
        var liveCount = 0
        var budget = 0
        var state = BudgetState.withinBudget
    }

    private struct Registry {
        var budgets: [String: TypeBudget] = [:]
        var trackedAddresses: Set<DisguisedAddress> = []
    }

    // MARK: - Properties

    private let registry = LockedState(Registry())

    // MARK: - Public Methods

    /// Counts a new instance of `typeName`.
    func register(_ address: DisguisedAddress, typeName: String, budget: Int) -> InstanceBudgetOutcome {
        registry.withLock { registry in
            guard registry.trackedAddresses.insert(address).inserted else { return .duplicate }
            var entry = registry.budgets[typeName] ?? TypeBudget()
            entry.liveCount += 1
            entry.budget = budget
            let outcome = Self.evaluate(&entry)
            registry.budgets[typeName] = entry
            return outcome
        }
    }

    /// Removes a deallocated instance of `typeName`.
    func unregister(_ address: DisguisedAddress, typeName: String) {
        registry.withLock { registry in
            guard registry.trackedAddresses.remove(address) != nil,
                  var entry = registry.budgets[typeName] else { return }
            entry.liveCount = max(0, entry.liveCount - 1)
            _ = Self.evaluate(&entry)
            registry.budgets[typeName] = entry
        }
    }

    // MARK: - Private Methods

    private static func evaluate(_ entry: inout TypeBudget) -> InstanceBudgetOutcome {
        guard entry.liveCount > entry.budget else {
            entry.state = .withinBudget
            return .withinBudget
        }
        guard entry.state == .withinBudget else { return .withinBudget }
        entry.state = .exceeded
        return .exceeded(liveCount: entry.liveCount)
    }
}
