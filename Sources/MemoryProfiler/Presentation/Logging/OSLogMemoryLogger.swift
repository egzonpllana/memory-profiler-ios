//
//  OSLogMemoryLogger.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
import os

/// Writes profiler messages to the unified logging system.
///
/// Filter in Console or Xcode with `subsystem:com.egzonpllana.MemoryProfiler`. Categories match
/// `MemoryLogCategory`. Messages are public because they only contain type names and addresses.
public struct OSLogMemoryLogger: MemoryLogging {

    // MARK: - Properties

    private let subsystem: String

    // MARK: - Initialization

    /// Creates a unified logging logger.
    ///
    /// - Parameter subsystem: Logging subsystem. Defaults to `com.egzonpllana.MemoryProfiler`.
    public init(subsystem: String = "com.egzonpllana.MemoryProfiler") {
        self.subsystem = subsystem
    }

    // MARK: - MemoryLogging

    public func log(_ message: String, level: MemoryLogLevel, category: MemoryLogCategory) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        switch level {
        case .debug:
            logger.debug("\(message, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)")
        case .warning:
            logger.warning("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        }
    }
}
