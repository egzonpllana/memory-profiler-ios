//
//  DelayedExecuting.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Runs work on the main thread after a delay.
///
/// Leak deadlines run on the main thread so the temporary strong reference taken while checking
/// an object is never the last one released off the main thread, which UIKit objects forbid.
protocol DelayedExecuting: Sendable {

    /// Runs `work` on the main thread after `delay`.
    func executeOnMain(after delay: Duration, _ work: @escaping @Sendable () -> Void)
}
