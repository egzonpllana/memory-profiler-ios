//
//  ScenarioCatalog.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// The scenarios shown in the list, grouped by SDK feature.
enum ScenarioCatalog {

    static let sections: [ScenarioSection] = [
        ScenarioSection(
            title: "Automatic UIKit tracking",
            footer: "Tap, then go back. Popped and dismissed view controllers are checked automatically.",
            scenarios: [
                Scenario(
                    action: .pushLeakyScreen,
                    title: "Screen with a retain cycle",
                    explanation: "The view model stores a closure that captures the screen strongly."
                ),
                Scenario(
                    action: .pushHealthyScreen,
                    title: "Screen without a retain cycle",
                    explanation: "Same screen with [weak self]. Expect no event."
                )
            ]
        ),
        ScenarioSection(
            title: "SwiftUI",
            footer: "detectLeaks(of:) checks the model when the view leaves the hierarchy.",
            scenarios: [
                Scenario(
                    action: .presentSwiftUIScreen,
                    title: "Model kept by a global registry",
                    explanation: "Close the sheet. The registry still holds the @StateObject model."
                )
            ]
        ),
        ScenarioSection(
            title: "Manual expectations",
            footer: "expectDeallocation(of:) and DeinitTracker mark the end of an object's scope.",
            scenarios: [
                Scenario(
                    action: .createDelegateCycle,
                    title: "Coordinator and child with strong delegates",
                    explanation: "Reports the leak and the cycle child -> delegate -> coordinator."
                ),
                Scenario(
                    action: .scheduleLateRelease,
                    title: "Late release",
                    explanation: "A pending 4s closure keeps the object alive: leak, then late release."
                )
            ]
        ),
        ScenarioSection(
            title: "Instance budgets and heap",
            footer: "Heap census and growth detection run in debug builds only.",
            scenarios: [
                Scenario(
                    action: .createSessionManager,
                    title: "Create a SessionManager (budget 1)",
                    explanation: "Tap twice: the second live instance exceeds the budget."
                ),
                Scenario(
                    action: .growThumbnailCache,
                    title: "Grow a cache that never evicts",
                    explanation: "Adds entries every 0.5s for 6s. Census sampling flags the growth."
                ),
                Scenario(
                    action: .takeHeapCensus,
                    title: "Heap census",
                    explanation: "Live instances and bytes per application class."
                )
            ]
        ),
        ScenarioSection(
            title: "Footprint monitoring",
            footer: "The threshold is set 200 MB above the launch footprint.",
            scenarios: [
                Scenario(
                    action: .allocateBallast,
                    title: "Allocate 250 MB",
                    explanation: "Crosses the warning threshold on the next sample."
                ),
                Scenario(
                    action: .releaseBallast,
                    title: "Release the 250 MB",
                    explanation: "Falls back below the threshold."
                ),
                Scenario(
                    action: .logMemoryUsage,
                    title: "Current footprint",
                    explanation: "Footprint, lifetime peak and limit from TASK_VM_INFO."
                )
            ]
        )
    ]
}
