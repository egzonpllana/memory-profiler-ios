//
//  ExpectationPhase.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Progress of a deallocation expectation.
enum ExpectationPhase: Sendable {

    /// Waiting for the deadline.
    case pending

    /// Alive past the deadline; retention analysis is running.
    case analyzing(LeakReport)

    /// Reported as leaked; waiting for a possible late release.
    case leaked(LeakReport)
}
