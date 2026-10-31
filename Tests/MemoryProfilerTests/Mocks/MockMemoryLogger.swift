//
//  MockMemoryLogger.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

final class MockMemoryLogger: MemoryLogging, @unchecked Sendable {
    private let entries = LockedState<[String]>([])

    var messages: [String] {
        entries.value
    }

    func log(_ message: String, level: MemoryLogLevel, category: MemoryLogCategory) {
        entries.withLock { $0.append(message) }
    }
}
