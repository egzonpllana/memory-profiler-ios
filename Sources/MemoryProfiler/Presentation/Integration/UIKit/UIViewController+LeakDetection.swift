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
    @objc dynamic func memoryProfilerViewDidDisappear(_ animated: Bool) {
        memoryProfilerViewDidDisappear(animated)
        ViewControllerLeakWatcher.shared.viewControllerDidDisappear(self)
    }
}
#endif
