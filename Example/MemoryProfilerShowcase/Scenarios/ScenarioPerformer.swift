//
//  ScenarioPerformer.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import MemoryProfiler
import SwiftUI
import UIKit

/// Runs scenario actions against real objects and screens.
@MainActor
final class ScenarioPerformer {

    // MARK: - Properties

    private static let ballastMegabytes = 250

    let navigation: UINavigationController
    private let profiler = MemoryProfilerService.shared
    private var sessions: [SessionManager] = []
    private var ballast: MemoryBallast?

    // MARK: - Initialization

    init(navigation: UINavigationController) {
        self.navigation = navigation
    }

    // MARK: - Public Methods

    /// Performs `action`. Returns an outcome when there is something to show immediately.
    func perform(_ action: ScenarioAction) -> ScenarioOutcome? {
        switch action {
        case .pushLeakyScreen, .pushHealthyScreen, .presentSwiftUIScreen:
            showScreen(for: action)
        case .createDelegateCycle:
            createDelegateCycle()
        case .scheduleLateRelease:
            scheduleLateRelease()
        case .createSessionManager:
            sessions.append(SessionManager())
        case .growThumbnailCache:
            ThumbnailCache.growForAWhile()
        case .allocateBallast, .releaseBallast:
            ballast = action == .allocateBallast ? MemoryBallast(megabytes: Self.ballastMegabytes) : nil
        case .takeHeapCensus:
            return heapCensusOutcome()
        case .logMemoryUsage:
            return memoryUsageOutcome()
        }
        return nil
    }

    // MARK: - Private Methods

    private func showScreen(for action: ScenarioAction) {
        switch action {
        case .pushLeakyScreen:
            navigation.pushViewController(LeakyDetailViewController(), animated: true)
        case .pushHealthyScreen:
            navigation.pushViewController(HealthyDetailViewController(), animated: true)
        case .presentSwiftUIScreen:
            navigation.present(UIHostingController(rootView: ProfileScreen()), animated: true)
        default:
            return
        }
    }

    private func createDelegateCycle() {
        let coordinator = CheckoutCoordinator()
        coordinator.startPayment()
        profiler.expectDeallocation(of: coordinator)
    }

    private func scheduleLateRelease() {
        let printer = ReceiptPrinter()
        printer.printAfterDelay()
        DeinitTracker.expectDeinit(of: printer)
    }

    private func heapCensusOutcome() -> ScenarioOutcome {
        do {
            let census = try profiler.heapCensus(limit: 10, scope: .applicationTypes)
            let lines = census.entries.map { "\($0.typeName): \($0.instanceCount) (\($0.totalBytes) bytes)" }
            return ScenarioOutcome(title: "Heap census", message: lines.joined(separator: "\n"))
        } catch {
            return ScenarioOutcome(title: "Heap census unavailable", message: "\(error)")
        }
    }

    private func memoryUsageOutcome() -> ScenarioOutcome {
        profiler.logMemoryUsage(context: "Showcase")
        let message = profiler.currentStats()?.description ?? "The profiler is inactive in this build."
        return ScenarioOutcome(title: "Footprint", message: message)
    }
}
