//
//  TestObjects.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

final class TrackedViewModel {
    var onUpdate: (() -> Void)?

    func bindStrongly() {
        onUpdate = { self.refresh() }
    }

    func refresh() {}
}

final class TrackedObjCObject: NSObject {}

final class ExemptCache: LeakDetectionExempt {}

final class CensusSubject {
    var payload = 0
}
