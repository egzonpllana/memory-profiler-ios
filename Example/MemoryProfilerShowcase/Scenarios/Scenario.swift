//
//  Scenario.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A showcase entry: what it does and what the profiler should report.
struct Scenario {
    let action: ScenarioAction
    let title: String
    let explanation: String
}

/// A group of scenarios demonstrating one SDK feature.
struct ScenarioSection {
    let title: String
    let footer: String
    let scenarios: [Scenario]
}
