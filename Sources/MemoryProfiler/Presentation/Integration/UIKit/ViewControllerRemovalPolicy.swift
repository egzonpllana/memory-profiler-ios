//
//  ViewControllerRemovalPolicy.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

/// Decides which view controllers are leaving for good when one disappears.
@MainActor
enum ViewControllerRemovalPolicy {

    /// Whether `viewController`, or one of its ancestors, is being popped, dismissed or removed
    /// from its parent. Tab switches and covering presentations do not count.
    static func isBeingRemoved(_ viewController: UIViewController) -> Bool {
        sequence(first: viewController) { $0.parent }.contains { $0.isMovingFromParent || $0.isBeingDismissed }
    }

    /// `viewController` and all of its descendants.
    static func releasedControllers(from viewController: UIViewController) -> [UIViewController] {
        [viewController] + viewController.children.flatMap { releasedControllers(from: $0) }
    }
}
#endif
