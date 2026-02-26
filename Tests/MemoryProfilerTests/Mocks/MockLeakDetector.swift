//
//  MockLeakDetector.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation
@testable import MemoryProfiler

final class MockLeakDetector: LeakDetecting {
    private(set) var trackedObjects: [ObjectIdentifier] = []
    private(set) var removedObjects: [ObjectIdentifier] = []
    private(set) var purgeCallCount = 0
    var stubbedLeaks: [MemoryLeakInfo] = []

    func trackObject(
        _ object: AnyObject,
        expectedLifetime: ObjectLifetime
    ) {
        trackedObjects.append(ObjectIdentifier(object))
    }

    func checkForLeaks() -> [MemoryLeakInfo] { stubbedLeaks }

    @discardableResult
    func removeTracking(for object: AnyObject) -> Bool {
        let identifier = ObjectIdentifier(object)
        removedObjects.append(identifier)
        return trackedObjects.contains(identifier)
    }

    func purgeReleasedObjects() {
        purgeCallCount += 1
    }
}
