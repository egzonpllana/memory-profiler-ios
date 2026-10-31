//
//  SessionManager.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import MemoryProfiler

/// Should exist once. `trackInstance(_:budget:)` reports a second live instance.
final class SessionManager {

    init() {
        MemoryProfilerService.shared.trackInstance(self, budget: 1)
    }
}
