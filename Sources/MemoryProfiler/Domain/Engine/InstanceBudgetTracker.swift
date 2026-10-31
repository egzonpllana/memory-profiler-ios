//
//  InstanceBudgetTracker.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Counts live instances per type and publishes budget violations.
final class InstanceBudgetTracker: Sendable {

    // MARK: - Properties

    private let dependencies: LeakDetectionDependencies
    private let registry = InstanceBudgetRegistry()

    // MARK: - Initialization

    init(dependencies: LeakDetectionDependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Public Methods

    func trackInstance(_ object: AnyObject, budget: Int, location: SourceLocation) {
        let descriptor = dependencies.inspector.describe(object)
        guard descriptor.allocationSize > 0 else { return }
        let address = DisguisedAddress(address: dependencies.inspector.address(of: object))
        let typeName = descriptor.typeName
        let outcome = registry.register(address, typeName: typeName, budget: budget)
        guard outcome != .duplicate else { return }
        dependencies.deallocationObserver.observeDeallocation(of: object) { [registry] in
            registry.unregister(address, typeName: typeName)
        }
        guard case .exceeded(let liveCount) = outcome else { return }
        let violation = InstanceBudgetViolation(
            typeName: typeName,
            liveCount: liveCount,
            budget: budget,
            location: location,
            detectedAt: dependencies.clock.now
        )
        dependencies.publisher.publish(.instanceBudgetExceeded(violation))
    }
}
