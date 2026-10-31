//
//  ReferrerGraphSearch.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Walks the heap breadth first from a leaked object toward the blocks that point at it.
struct ReferrerGraphSearch {

    // MARK: - Properties

    private static let depthLimit = 1...5
    private static let reportedReferrerLimit = 64

    let root: DisguisedAddress
    let rootTypeName: String
    let maxDepth: Int
    let ignoredBlocks: [UInt]
    let classifier: any TypeOriginClassifying

    // MARK: - Public Methods

    /// Runs the search. Throws when the heap cannot be walked.
    func run() throws -> RetentionAnalysis {
        let describer = ReferrerDescriber(catalog: RuntimeClassCatalog.current(), classifier: classifier)
        var state = ReferrerSearchState(root: root)
        let depthCount = min(max(maxDepth, Self.depthLimit.lowerBound), Self.depthLimit.upperBound)
        for depth in 1...depthCount where !state.frontier.isEmpty && !state.hasFrameworkFreeCycle {
            let result = try HeapReferenceScan.scan(
                targets: state.frontier.map(\.address),
                ignoredBlocks: ignoredBlocks
            )
            state.absorb(result, depth: depth, describer: describer)
        }
        return makeAnalysis(from: state)
    }

    // MARK: - Private Methods

    private func makeAnalysis(from state: ReferrerSearchState) -> RetentionAnalysis {
        let cycle = state.bestCycle.map { RetentionCycle(rootTypeName: rootTypeName, path: $0.path) }
        let isTruncated = state.isTruncated || state.referrers.count > Self.reportedReferrerLimit
        return RetentionAnalysis(
            referrers: Array(state.referrers.prefix(Self.reportedReferrerLimit)),
            cycle: cycle,
            completeness: isTruncated ? .truncated : .complete
        )
    }
}
