//
//  FixedTimeProvider.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

final class FixedTimeProvider: TimeProviding, @unchecked Sendable {
    private let current = LockedState(Date(timeIntervalSince1970: 1_000))

    var now: Date {
        current.value
    }

    func advance(by interval: TimeInterval) {
        current.withLock { $0 = $0.addingTimeInterval(interval) }
    }
}
