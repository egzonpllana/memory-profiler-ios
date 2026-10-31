//
//  CycleCandidate.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A cycle found by the referrer search, ranked by how plausibly it explains the leak.
///
/// The conservative scan also closes cycles through framework back-pointers that are not
/// ownership, such as a view's unretained pointer to its view controller. Cycles that avoid
/// framework classes and pass through application classes are the ones worth reporting.
struct CycleCandidate {

    // MARK: - Properties

    /// Referrers in order, starting with the root's own field.
    let path: [RetentionReferrer]

    /// Framework classes on the path, excluding the root.
    let systemNodeCount: Int

    /// Application classes on the path, excluding the root.
    let applicationNodeCount: Int

    /// Whether the path avoids framework classes entirely.
    var isFrameworkFree: Bool {
        systemNodeCount == 0
    }

    // MARK: - Initialization

    init(path: [RetentionReferrer], origins: [ReferrerOrigin]) {
        self.path = path
        systemNodeCount = origins.filter { $0 == .system }.count
        applicationNodeCount = origins.filter { $0 == .application }.count
    }

    // MARK: - Ranking

    /// Whether this candidate explains the leak better than `other`.
    func ranksAbove(_ other: CycleCandidate) -> Bool {
        guard systemNodeCount == other.systemNodeCount else {
            return systemNodeCount < other.systemNodeCount
        }
        guard applicationNodeCount == other.applicationNodeCount else {
            return applicationNodeCount > other.applicationNodeCount
        }
        return path.count < other.path.count
    }
}
