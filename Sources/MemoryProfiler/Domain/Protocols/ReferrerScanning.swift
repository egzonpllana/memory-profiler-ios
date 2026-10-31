//
//  ReferrerScanning.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Explains who keeps a leaked object alive.
protocol ReferrerScanning: Sendable {

    /// Scans the heap for referrers of `root` on a background queue and calls `completion` there.
    /// Passes `nil` when introspection is unavailable.
    ///
    /// - Parameters:
    ///   - root: Disguised address of the leaked object.
    ///   - rootTypeName: Type name of the leaked object, used in the cycle description.
    ///   - maxDepth: Maximum breadth-first depth.
    ///   - ignoredBlocks: Block addresses owned by the profiler that must not be reported.
    ///   - completion: Receives the analysis.
    func analyzeRetention(
        of root: DisguisedAddress,
        rootTypeName: String,
        maxDepth: Int,
        ignoredBlocks: [UInt],
        completion: @escaping @Sendable (RetentionAnalysis?) -> Void
    )
}
