//
//  RetentionAnalysisCompleteness.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Whether a retention scan saw every referrer.
public enum RetentionAnalysisCompleteness: Sendable, Equatable {

    /// Every referrer within the depth limit was recorded.
    case complete

    /// A buffer or frontier limit was reached; some referrers are missing.
    case truncated
}
