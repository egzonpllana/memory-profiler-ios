//
//  MockRepeatingScheduler.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

final class MockRepeatingScheduler: RepeatingScheduling, @unchecked Sendable {
    private let handler = LockedState<(@Sendable () -> Void)?>(nil)
    private(set) var startCount = 0
    private(set) var stopCount = 0
    private(set) var lastInterval: Duration?

    var isActive: Bool {
        handler.value != nil
    }

    func start(interval: Duration, handler: @escaping @Sendable () -> Void) {
        startCount += 1
        lastInterval = interval
        self.handler.withLock { $0 = handler }
    }

    func stop() {
        stopCount += 1
        handler.withLock { $0 = nil }
    }

    func fire() {
        handler.value?()
    }
}
