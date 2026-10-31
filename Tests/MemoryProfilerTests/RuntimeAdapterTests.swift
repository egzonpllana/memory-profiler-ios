//
//  RuntimeAdapterTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import XCTest
@testable import MemoryProfiler

final class RuntimeAdapterTests: XCTestCase {

    func testMachReaderReportsFootprint() throws {
        let stats = try XCTUnwrap(MachMemoryReader().readStats())

        XCTAssertGreaterThan(stats.footprint, 0)
        XCTAssertGreaterThanOrEqual(stats.peakFootprint, stats.footprint)
        XCTAssertEqual(stats.physicalMemory, ProcessInfo.processInfo.physicalMemory)
    }

    func testDeallocationObserverFiresForSwiftAndObjectiveCObjects() {
        let observer = AssociatedObjectDeallocationObserver()
        let fired = LockedState(0)
        autoreleasepool {
            let swiftObject = TrackedViewModel()
            let objcObject = TrackedObjCObject()
            observer.observeDeallocation(of: swiftObject) { fired.withLock { $0 += 1 } }
            observer.observeDeallocation(of: swiftObject) { fired.withLock { $0 += 1 } }
            observer.observeDeallocation(of: objcObject) { fired.withLock { $0 += 1 } }
        }

        XCTAssertEqual(fired.value, 3)
    }

    func testClassifierSeparatesSystemAndApplicationClasses() {
        let classifier = RuntimeTypeOriginClassifier()

        XCTAssertTrue(classifier.isSystemClass(NSObject.self))
        XCTAssertTrue(classifier.isSystemClass(LeakDetectionEngine.self))
        XCTAssertFalse(classifier.isSystemClass(TrackedViewModel.self))
    }

    func testSideTableDecoding() {
        let word: UInt = 0xC000_0001_14DA_39BC

        XCTAssertEqual(SwiftSideTable.address(fromReferenceCountWord: word), 0x8_A6D1_CDE0)
        XCTAssertNil(SwiftSideTable.address(fromReferenceCountWord: 0x0000_0003_0000_0000))
    }
}
