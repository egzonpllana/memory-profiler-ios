//
//  CrashSafetyFixtures.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Distributed
import Foundation
@testable import MemoryProfiler

/// Expects its own deallocation from `deinit`, the misuse that used to abort in `objc_initWeak`.
final class SelfExpectingObjCObject: NSObject {
    let engine: LeakDetectionEngine

    init(engine: LeakDetectionEngine) {
        self.engine = engine
    }

    deinit {
        let location = SourceLocation(fileID: "Tests", line: 1, function: "deinit")
        let request = DeallocationRequest(gracePeriod: nil, reason: .manual, location: location, usageProbe: nil)
        engine.expectDeallocation(of: self, request: request)
    }
}

actor TrackedActor {}

distributed actor TrackedDistributedActor {
    typealias ActorSystem = LocalTestingDistributedActorSystem
}

/// Cancels another subscription when released, the pattern that used to re-enter the broadcaster lock.
final class SubscriptionCanceller: @unchecked Sendable {
    let other: EventSubscription

    init(other: EventSubscription) {
        self.other = other
    }

    deinit {
        other.cancel()
    }
}

/// Calls back into the profiler from `log`, the pattern that used to re-enter the state lock.
final class ReentrantLogger: MemoryLogging, @unchecked Sendable {
    private let target = LockedState<MemoryProfilerService?>(nil)
    private let calls = LockedState(0)

    var callCount: Int {
        calls.value
    }

    func attach(_ service: MemoryProfilerService) {
        target.withLock { $0 = service }
    }

    func log(_ message: String, level: MemoryLogLevel, category: MemoryLogCategory) {
        calls.withLock { $0 += 1 }
        target.value?.stop()
    }
}
