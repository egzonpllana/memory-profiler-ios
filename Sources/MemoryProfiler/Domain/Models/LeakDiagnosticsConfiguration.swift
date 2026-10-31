//
//  LeakDiagnosticsConfiguration.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Extra context collected for each leak report.
public struct LeakDiagnosticsConfiguration: Sendable, Equatable {

    // MARK: - Properties

    /// Whether the call stack is captured when an object is expected to deallocate.
    public var capturesCallStack: Bool

    /// Retention analysis performed once a leak is confirmed.
    public var retentionAnalysis: RetentionAnalysisMode

    // MARK: - Initialization

    /// Creates a diagnostics configuration.
    ///
    /// - Parameters:
    ///   - capturesCallStack: Whether to capture the call stack of each expectation. Defaults to `true`.
    ///   - retentionAnalysis: Retention analysis mode. Defaults to `.disabled`.
    public init(capturesCallStack: Bool = true, retentionAnalysis: RetentionAnalysisMode = .disabled) {
        self.capturesCallStack = capturesCallStack
        self.retentionAnalysis = retentionAnalysis
    }
}
