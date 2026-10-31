//
//  Duration+TimeInterval.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

extension Duration {

    /// The duration in seconds as a `TimeInterval`.
    var timeInterval: TimeInterval {
        let parts = components
        return TimeInterval(parts.seconds) + TimeInterval(parts.attoseconds) / 1e18
    }

    /// The duration as a dispatch interval, clamped to valid nanosecond values.
    var dispatchInterval: DispatchTimeInterval {
        let nanoseconds = max(0, timeInterval * 1e9)
        guard nanoseconds < 9e18 else { return .never }
        return .nanoseconds(Int(nanoseconds))
    }
}
