//
//  MemoryProfilerService+Leaks.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

extension MemoryProfilerService {

    public func expectDeallocation(
        of object: AnyObject,
        gracePeriod: Duration?,
        reason: DeallocationExpectationReason,
        location: SourceLocation
    ) {
        guard isActive else { return }
        let request = DeallocationRequest(gracePeriod: gracePeriod, reason: reason, location: location, usageProbe: nil)
        components.leakDetector.expectDeallocation(of: object, request: request)
    }

    public func trackInstance(_ object: AnyObject, budget: Int, location: SourceLocation) {
        guard isActive else { return }
        components.leakDetector.trackInstance(object, budget: max(0, budget), location: location)
    }

    public func currentLeaks() -> [LeakReport] {
        guard isActive else { return [] }
        return components.leakDetector.currentLeaks()
    }
}
