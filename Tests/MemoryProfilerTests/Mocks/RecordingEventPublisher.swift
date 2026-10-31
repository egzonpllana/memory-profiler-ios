//
//  RecordingEventPublisher.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

final class RecordingEventPublisher: MemoryEventPublishing, @unchecked Sendable {
    private let recorded = LockedState<[MemoryProfilerEvent]>([])

    var events: [MemoryProfilerEvent] {
        recorded.value
    }

    var detectedLeaks: [LeakReport] {
        events.compactMap { event in
            guard case .leakDetected(let report) = event else { return nil }
            return report
        }
    }

    var resolutions: [LeakResolution] {
        events.compactMap { event in
            guard case .leakResolved(let resolution) = event else { return nil }
            return resolution
        }
    }

    var budgetViolations: [InstanceBudgetViolation] {
        events.compactMap { event in
            guard case .instanceBudgetExceeded(let violation) = event else { return nil }
            return violation
        }
    }

    func publish(_ event: MemoryProfilerEvent) {
        recorded.withLock { $0.append(event) }
    }
}
