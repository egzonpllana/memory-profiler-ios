//
//  SystemMemoryMonitorTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import XCTest
@testable import MemoryProfiler

final class SystemMemoryMonitorTests: XCTestCase {

    private var monitor: SystemMemoryMonitor {
        SystemMemoryMonitor()
    }

    func testCurrentMemoryUsageReturnsNonZero() {
        let usage = monitor.currentMemoryUsage()
        XCTAssertGreaterThan(usage, 0)
    }

    func testTotalMemoryMatchesProcessInfo() {
        let total = monitor.totalMemory()
        let expected = ProcessInfo.processInfo.physicalMemory
        XCTAssertEqual(total, expected)
    }

    func testUsedMemoryIsLessThanTotal() {
        let used = monitor.currentMemoryUsage()
        let total = monitor.totalMemory()
        XCTAssertLessThan(used, total)
    }
}
