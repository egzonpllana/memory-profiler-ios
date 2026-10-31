//
//  ScenarioAction.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Every action the showcase can trigger.
enum ScenarioAction: CaseIterable {
    case pushLeakyScreen
    case pushHealthyScreen
    case presentSwiftUIScreen
    case createDelegateCycle
    case scheduleLateRelease
    case createSessionManager
    case growThumbnailCache
    case allocateBallast
    case releaseBallast
    case takeHeapCensus
    case logMemoryUsage
}
