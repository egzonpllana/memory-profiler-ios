//
//  ReferrerSearchState.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Breadth-first search state over heap referrers. Every stored address is disguised so the
/// search's own memory is never mistaken for a referrer by later walks.
struct ReferrerSearchState {

    // MARK: - Properties

    private static let cycleCandidateLimit = 16

    let root: DisguisedAddress
    private(set) var frontier: [DisguisedAddress]
    private(set) var referrers: [RetentionReferrer] = []
    private(set) var cycleCandidates: [CycleCandidate] = []
    private(set) var isTruncated = false
    private var nodes: [DisguisedAddress: ReferrerNode] = [:]
    private var visited: Set<DisguisedAddress>

    /// Whether a cycle without framework classes was found; deeper walks cannot improve on it.
    var hasFrameworkFreeCycle: Bool {
        cycleCandidates.contains(where: \.isFrameworkFree)
    }

    /// The cycle that best explains the leak.
    var bestCycle: CycleCandidate? {
        cycleCandidates.reduce(nil) { best, candidate in
            guard let best else { return candidate }
            return candidate.ranksAbove(best) ? candidate : best
        }
    }

    // MARK: - Initialization

    init(root: DisguisedAddress) {
        self.root = root
        frontier = [root]
        visited = [root]
    }

    // MARK: - Public Methods

    /// Adds the hits of one walk and prepares the next frontier.
    mutating func absorb(_ result: HeapReferenceScanResult, depth: Int, describer: ReferrerDescriber) {
        isTruncated = isTruncated || result.isTruncated
        var nextFrontier: [DisguisedAddress] = []
        for hit in result.hits where !result.sideTables.contains(hit.block) {
            let description = describer.describe(hit, depth: depth)
            if hit.block == root {
                recordCycle(closingWith: description, target: hit.target)
            } else if visited.insert(hit.block).inserted {
                nodes[hit.block] = ReferrerNode(description: description, target: hit.target)
                referrers.append(description.referrer)
                appendToFrontier(hit.block, frontier: &nextFrontier)
            }
        }
        frontier = nextFrontier
    }

    // MARK: - Private Methods

    private mutating func appendToFrontier(_ block: DisguisedAddress, frontier: inout [DisguisedAddress]) {
        guard frontier.count < HeapReferenceScan.targetCapacity else {
            isTruncated = true
            return
        }
        frontier.append(block)
    }

    /// The root points to `target`, which leads back to the root through recorded nodes.
    private mutating func recordCycle(closingWith rootDescription: ReferrerDescription, target: DisguisedAddress) {
        guard cycleCandidates.count < Self.cycleCandidateLimit else { return }
        var path = [rootDescription.referrer]
        var origins: [ReferrerOrigin] = []
        var current = target
        while current != root, let node = nodes[current], path.count <= nodes.count {
            path.append(node.description.referrer)
            origins.append(node.description.origin)
            current = node.target
        }
        cycleCandidates.append(CycleCandidate(path: path, origins: origins))
    }
}
