//
//  MockMemoryMonitor.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation
@testable import MemoryProfiler

final class MockMemoryMonitor: MemoryMonitoring, @unchecked Sendable {
    var stubbedUsage: UInt64 = 100_000_000
    var stubbedTotal: UInt64 = 4_000_000_000

    func currentMemoryUsage() -> UInt64 { stubbedUsage }
    func totalMemory() -> UInt64 { stubbedTotal }
}
