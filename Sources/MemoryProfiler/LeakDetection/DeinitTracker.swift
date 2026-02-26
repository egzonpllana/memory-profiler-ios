//
//  DeinitTracker.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

/// Lightweight utility that verifies an object is deallocated within a delay.
///
/// Call `expectDeinit(of:)` right before releasing your reference.
/// If the object is still alive after the delay, a warning is logged.
/// Works standalone — no profiler setup required.
///
/// ```swift
/// // When dismissing a screen:
/// DeinitTracker.expectDeinit(of: viewModel)
/// ```
public enum DeinitTracker {

    /// Asserts that the given object will be deallocated within the delay.
    ///
    /// Captures a weak reference, then checks after `delay` seconds.
    /// If the object is still alive, a warning is printed (DEBUG only).
    ///
    /// - Parameters:
    ///   - object: The object expected to be deallocated.
    ///   - delay: Seconds to wait before checking. Default is 2.
    ///   - file: Source file (auto-captured).
    ///   - line: Source line (auto-captured).
    public static func expectDeinit(
        of object: AnyObject,
        after delay: TimeInterval = 2.0,
        file: String = #file,
        line: Int = #line
    ) {
        let typeName = String(describing: type(of: object))
        weak var weakRef: AnyObject? = object

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard weakRef != nil else { return }
            DebugLog.log(
                "[MemoryProfiler] Potential leak: \(typeName)"
                + " was not deallocated after \(delay)s"
                + " (\(file):\(line))"
            )
        }
    }
}
