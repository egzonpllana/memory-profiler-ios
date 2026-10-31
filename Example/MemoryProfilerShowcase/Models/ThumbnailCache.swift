//
//  ThumbnailCache.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// An entry of a cache that never evicts.
final class ThumbnailCacheEntry {
    let pixels = [UInt8](repeating: 0, count: 512)
}

/// A cache that only grows; allocation growth detection flags `ThumbnailCacheEntry`.
@MainActor
enum ThumbnailCache {

    private static var entries: [ThumbnailCacheEntry] = []

    /// Adds 10 entries every half second for 6 seconds.
    static func growForAWhile() {
        Task { @MainActor in
            for _ in 0..<12 {
                entries.append(contentsOf: (0..<10).map { _ in ThumbnailCacheEntry() })
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }
}
