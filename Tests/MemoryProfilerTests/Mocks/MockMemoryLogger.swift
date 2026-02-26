//
//  MockMemoryLogger.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation
@testable import MemoryProfiler

final class MockMemoryLogger: MemoryLogging {
    private(set) var loggedMessages: [String] = []
    private(set) var loggedWarnings: [String] = []

    func log(_ message: String) {
        loggedMessages.append(message)
    }

    func logWarning(_ message: String) {
        loggedWarnings.append(message)
    }
}
