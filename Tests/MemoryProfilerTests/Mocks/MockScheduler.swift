//
//  MockScheduler.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation
@testable import MemoryProfiler

final class MockScheduler: MonitoringScheduling {
    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0
    private(set) var lastInterval: TimeInterval?
    private(set) var lastHandler: (() -> Void)?
    var isActive: Bool { startCallCount > stopCallCount }

    func start(interval: TimeInterval, handler: @escaping () -> Void) {
        startCallCount += 1
        lastInterval = interval
        lastHandler = handler
    }

    func stop() {
        stopCallCount += 1
    }

    func simulateTick() {
        lastHandler?()
    }
}
