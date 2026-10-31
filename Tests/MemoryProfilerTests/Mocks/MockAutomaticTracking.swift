//
//  MockAutomaticTracking.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

final class MockAutomaticTracking: AutomaticTrackingInstalling, @unchecked Sendable {
    private(set) var attachCount = 0
    private(set) var detachCount = 0

    func attach(_ detector: any LeakDetecting, configuration: LeakDetectionConfiguration) {
        attachCount += 1
    }

    func detach() {
        detachCount += 1
    }
}
