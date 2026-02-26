//
//  WeakReferenceTrackerTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import XCTest
@testable import MemoryProfiler

final class WeakReferenceTrackerTests: XCTestCase {

    private var tracker: WeakReferenceTracker {
        WeakReferenceTracker(scopeGracePeriod: 0.1)
    }

    func testDeallocatedObjectIsNotReportedAsLeak() {
        let sut = tracker
        autoreleasepool {
            let object = NSObject()
            sut.trackObject(object, expectedLifetime: .scopeBound)
        }

        let expectation = expectation(description: "grace period")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        let leaks = sut.checkForLeaks()
        XCTAssertTrue(leaks.isEmpty)
    }

    func testRetainedObjectIsReportedAsLeak() {
        let sut = tracker
        let retained = NSObject()
        sut.trackObject(retained, expectedLifetime: .scopeBound)

        let expectation = expectation(description: "grace period")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        let leaks = sut.checkForLeaks()
        XCTAssertEqual(leaks.count, 1)
        XCTAssertEqual(leaks.first?.objectType, "NSObject")
    }

    func testTimeBoundObjectReportedAfterExpiry() {
        let sut = tracker
        let retained = NSObject()
        sut.trackObject(
            retained,
            expectedLifetime: .timeBound(seconds: 0.1)
        )

        let expectation = expectation(description: "time bound")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        let leaks = sut.checkForLeaks()
        XCTAssertEqual(leaks.count, 1)
    }

    func testRemoveTrackingStopsDetection() {
        let sut = tracker
        let object = NSObject()
        sut.trackObject(object, expectedLifetime: .scopeBound)
        let removed = sut.removeTracking(for: object)

        XCTAssertTrue(removed)

        let expectation = expectation(description: "grace period")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        let leaks = sut.checkForLeaks()
        XCTAssertTrue(leaks.isEmpty)
    }

    func testPurgeRemovesDeallocatedEntries() {
        let sut = tracker
        autoreleasepool {
            let object = NSObject()
            sut.trackObject(object, expectedLifetime: .scopeBound)
        }
        sut.purgeReleasedObjects()

        let leaks = sut.checkForLeaks()
        XCTAssertTrue(leaks.isEmpty)
    }
}
