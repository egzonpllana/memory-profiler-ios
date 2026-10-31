//
//  MockPressureObserver.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

final class MockPressureObserver: MemoryPressureObserving, @unchecked Sendable {
    private let handler = LockedState<(@Sendable (MemoryPressureLevel) -> Void)?>(nil)
    private(set) var stopCount = 0

    var isObserving: Bool {
        handler.value != nil
    }

    func startObserving(_ handler: @escaping @Sendable (MemoryPressureLevel) -> Void) {
        self.handler.withLock { $0 = handler }
    }

    func stopObserving() {
        stopCount += 1
        handler.withLock { $0 = nil }
    }

    func simulate(_ level: MemoryPressureLevel) {
        handler.value?(level)
    }
}
