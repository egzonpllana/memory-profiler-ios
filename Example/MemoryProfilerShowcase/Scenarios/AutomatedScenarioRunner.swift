//
//  AutomatedScenarioRunner.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import MemoryProfiler
import UIKit

/// Runs every scenario unattended (launch argument `-runAllScenarios`), prints a transcript and exits.
/// Add `-keepRunning` to stay open on the Events tab instead.
@MainActor
final class AutomatedScenarioRunner {

    // MARK: - Properties

    private let performer: ScenarioPerformer
    private let feed: EventFeed

    // MARK: - Initialization

    init(performer: ScenarioPerformer, feed: EventFeed) {
        self.performer = performer
        self.feed = feed
    }

    // MARK: - Public Methods

    func run() async {
        await pause(1)
        await runUIKitScenarios()
        await runSwiftUIScenario()
        await runManualScenarios()
        await runBudgetAndHeapScenarios()
        await runFootprintScenarios()
        printSummary()
        guard !ProcessInfo.processInfo.arguments.contains("-keepRunning") else {
            performer.navigation.tabBarController?.selectedIndex = 1
            return
        }
        await pause(1)
        exit(0)
    }

    // MARK: - Scenarios

    private func runUIKitScenarios() async {
        announce("Push and pop a screen whose view model closure captures it strongly")
        await pushAndPop(.pushLeakyScreen)
        announce("Control: push and pop the same screen using [weak self]")
        await pushAndPop(.pushHealthyScreen)
        await pause(3)
    }

    private func runSwiftUIScenario() async {
        announce("Present and dismiss a SwiftUI screen whose model is kept by a global registry")
        _ = performer.perform(.presentSwiftUIScreen)
        await pause(1)
        performer.navigation.dismiss(animated: false)
        await pause(3)
    }

    private func runManualScenarios() async {
        announce("Coordinator and payment flow holding each other strongly, then expectDeallocation")
        _ = performer.perform(.createDelegateCycle)
        announce("Object kept alive for 4 seconds by a pending closure, then DeinitTracker")
        _ = performer.perform(.scheduleLateRelease)
        await pause(5)
    }

    private func runBudgetAndHeapScenarios() async {
        announce("Two SessionManager instances with an instance budget of 1")
        _ = performer.perform(.createSessionManager)
        _ = performer.perform(.createSessionManager)
        announce("A cache that keeps growing")
        _ = performer.perform(.growThumbnailCache)
        await pause(6)
        announce("Heap census")
        report(performer.perform(.takeHeapCensus))
    }

    private func runFootprintScenarios() async {
        announce("Allocate 250 MB, then release it")
        _ = performer.perform(.allocateBallast)
        await pause(4)
        _ = performer.perform(.releaseBallast)
        await pause(4)
        report(performer.perform(.logMemoryUsage))
    }

    // MARK: - Private Methods

    private func pushAndPop(_ action: ScenarioAction) async {
        _ = performer.perform(action)
        await pause(1)
        performer.navigation.popViewController(animated: false)
    }

    private func announce(_ title: String) {
        Transcript.write("\n=== \(title)")
    }

    private func report(_ outcome: ScenarioOutcome?) {
        guard let outcome else { return }
        Transcript.write("--- \(outcome.title)\n\(outcome.message)")
    }

    private func printSummary() {
        let kinds: [EventKind] = [.leak, .lateRelease, .budget, .growth, .threshold, .pressure]
        Transcript.write("\n=== SUMMARY")
        for kind in kinds {
            Transcript.write("  \(kind.rawValue): \(feed.count(of: kind))")
        }
        let leaked = MemoryProfilerService.shared.currentLeaks().map(\.object.typeName).sorted()
        Transcript.write("  currently leaked: \(leaked)")
    }

    private func pause(_ seconds: Double) async {
        try? await Task.sleep(for: .milliseconds(Int(seconds * 1_000)))
    }
}
