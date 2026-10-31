//
//  ViewControllerLifecycleHook.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#if canImport(UIKit) && !os(watchOS)
import ObjectiveC
import UIKit

/// Installs the `viewDidDisappear(_:)` hook once per process.
enum ViewControllerLifecycleHook {

    // MARK: - Properties

    /// Lazily initialized exactly once, thread-safely, by the Swift runtime.
    private static let isInstalled: Bool = exchangeImplementations()

    // MARK: - Public Methods

    /// Installs the hook if it is not installed yet.
    static func installIfNeeded() {
        _ = isInstalled
    }

    // MARK: - Private Methods

    private static func exchangeImplementations() -> Bool {
        let originalSelector = #selector(UIViewController.viewDidDisappear(_:))
        let replacementSelector = #selector(UIViewController.memoryProfilerViewDidDisappear(_:))
        guard let original = class_getInstanceMethod(UIViewController.self, originalSelector),
              let replacement = class_getInstanceMethod(UIViewController.self, replacementSelector) else {
            return false
        }
        method_exchangeImplementations(original, replacement)
        return true
    }
}
#endif
