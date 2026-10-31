//
//  MemoryLogging.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Destination for profiler log messages.
///
/// The default implementation writes to the unified logging system. Provide your own to forward
/// messages to an existing logging stack. Implementations are called from arbitrary threads and
/// must not call back into the profiler synchronously.
public protocol MemoryLogging: Sendable {

    /// Writes one message.
    ///
    /// - Parameters:
    ///   - message: The message text.
    ///   - level: Severity.
    ///   - category: Profiler area the message belongs to.
    func log(_ message: String, level: MemoryLogLevel, category: MemoryLogCategory)
}
