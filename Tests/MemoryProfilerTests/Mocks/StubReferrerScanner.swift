//
//  StubReferrerScanner.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

/// Returns a preset analysis. Completion runs when `complete()` is called.
final class StubReferrerScanner: ReferrerScanning, @unchecked Sendable {
    private let pendingCompletion = LockedState<(@Sendable (RetentionAnalysis?) -> Void)?>(nil)
    private let analysis: RetentionAnalysis?
    private(set) var ignoredBlocks: [UInt] = []

    init(analysis: RetentionAnalysis?) {
        self.analysis = analysis
    }

    func analyzeRetention(
        of root: DisguisedAddress,
        rootTypeName: String,
        maxDepth: Int,
        ignoredBlocks: [UInt],
        completion: @escaping @Sendable (RetentionAnalysis?) -> Void
    ) {
        self.ignoredBlocks = ignoredBlocks
        pendingCompletion.withLock { $0 = completion }
    }

    func complete() {
        pendingCompletion.value?(analysis)
    }
}
