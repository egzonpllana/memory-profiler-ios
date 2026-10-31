//
//  LeakDetectionFilter.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Rules that exclude objects from leak detection.
public struct LeakDetectionFilter: Sendable, Equatable {

    // MARK: - Properties

    /// Fully qualified type names that are never reported, for example `"MyApp.ImageCache"`.
    public var ignoredTypeNames: Set<String>

    /// Whether automatic tracking skips view controllers and views defined by Apple frameworks.
    public var ignoresSystemTypes: Bool

    // MARK: - Initialization

    /// Creates a leak detection filter.
    ///
    /// - Parameters:
    ///   - ignoredTypeNames: Fully qualified type names that are never reported.
    ///   - ignoresSystemTypes: Whether automatic tracking skips Apple framework types. Defaults to `true`.
    public init(ignoredTypeNames: Set<String> = [], ignoresSystemTypes: Bool = true) {
        self.ignoredTypeNames = ignoredTypeNames
        self.ignoresSystemTypes = ignoresSystemTypes
    }
}
