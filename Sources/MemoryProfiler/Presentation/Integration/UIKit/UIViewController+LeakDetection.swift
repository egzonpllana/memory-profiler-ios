//
//  UIViewController+LeakDetection.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

extension UIViewController {

    /// Exchanged with `viewDidDisappear(_:)`: calling it runs the original implementation.
    ///
    /// Nonisolated on purpose: a main-actor `@objc` method traps in Swift 6 when called off the main
    /// queue. Code that calls `viewDidDisappear` from another queue keeps its old behavior and is not tracked.
    @objc dynamic nonisolated func memoryProfilerViewDidDisappear(_ animated: Bool) {
        memoryProfilerViewDidDisappear(animated)
        guard MainQueueDetector.isOnMainQueue else { return }
        MainActor.assumeIsolated {
            ViewControllerLeakWatcher.shared.viewControllerDidDisappear(self)
        }
    }
}
#endif
