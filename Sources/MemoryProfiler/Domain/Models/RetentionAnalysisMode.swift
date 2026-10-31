//
//  RetentionAnalysisMode.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// How the profiler explains who keeps a leaked object alive.
public enum RetentionAnalysisMode: Sendable, Equatable {

    /// No analysis. Reports carry the address for the Debug Memory Graph.
    case disabled

    /// Experimental. Scans the heap for blocks that point at the leaked object, breadth first,
    /// up to `maxDepth` levels, and reports a retain cycle when the chain leads back to it.
    ///
    /// Available in debug builds only. The scan briefly pauses every allocating thread and is
    /// conservative: Objective-C `weak` and Swift `unowned` references can appear as edges.
    case referrerScan(maxDepth: Int)
}
