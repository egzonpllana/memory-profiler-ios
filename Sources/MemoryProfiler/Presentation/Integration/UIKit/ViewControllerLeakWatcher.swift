//
//  ViewControllerLeakWatcher.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

/// Creates deallocation expectations for view controllers that are popped, dismissed or
/// removed from their parent, and for their views.
final class ViewControllerLeakWatcher: AutomaticTrackingInstalling {

    // MARK: - Types

    private struct Attachment {
        weak var detector: (any LeakDetecting)?
        let configuration: LeakDetectionConfiguration
    }

    // MARK: - Properties

    /// The watcher the swizzled lifecycle method reports to.
    static let shared = ViewControllerLeakWatcher(classifier: RuntimeTypeOriginClassifier())

    private static let automaticLocation = SourceLocation(fileID: "UIKit", line: 0, function: "viewDidDisappear(_:)")

    private let attachment = LockedState<Attachment?>(nil)
    private let classifier: any TypeOriginClassifying

    // MARK: - Initialization

    init(classifier: any TypeOriginClassifying) {
        self.classifier = classifier
    }

    // MARK: - AutomaticTrackingInstalling

    func attach(_ detector: any LeakDetecting, configuration: LeakDetectionConfiguration) {
        ViewControllerLifecycleHook.installIfNeeded()
        attachment.withLock { $0 = Attachment(detector: detector, configuration: configuration) }
    }

    func detach() {
        attachment.withLock { $0 = nil }
    }

    // MARK: - Lifecycle Callbacks

    /// Called after every `viewDidDisappear(_:)` while the hook is installed.
    @MainActor
    func viewControllerDidDisappear(_ viewController: UIViewController) {
        guard let current = attachment.value,
              let detector = current.detector,
              ViewControllerRemovalPolicy.isBeingRemoved(viewController) else { return }
        let controllers = ViewControllerRemovalPolicy.releasedControllers(from: viewController)
        for controller in controllers where shouldTrack(controller, filter: current.configuration.filter) {
            expect(controller, targets: current.configuration.automaticTracking, detector: detector)
        }
    }

    // MARK: - Private Methods

    @MainActor
    private func shouldTrack(_ controller: UIViewController, filter: LeakDetectionFilter) -> Bool {
        !(filter.ignoresSystemTypes && classifier.isSystemClass(type(of: controller)))
    }

    @MainActor
    private func expect(
        _ controller: UIViewController,
        targets: Set<AutomaticTrackingTarget>,
        detector: any LeakDetecting
    ) {
        if targets.contains(.viewControllers) {
            let request = Self.request(.viewControllerRemoved, ViewControllerUsageProbe())
            detector.expectDeallocation(of: controller, request: request)
        }
        if targets.contains(.views), let view = controller.viewIfLoaded {
            let request = Self.request(.viewOfRemovedController, ViewUsageProbe())
            detector.expectDeallocation(of: view, request: request)
        }
    }

    private static func request(
        _ reason: DeallocationExpectationReason,
        _ probe: any ObjectUsageProbing
    ) -> DeallocationRequest {
        DeallocationRequest(gracePeriod: nil, reason: reason, location: automaticLocation, usageProbe: probe)
    }
}
#endif
