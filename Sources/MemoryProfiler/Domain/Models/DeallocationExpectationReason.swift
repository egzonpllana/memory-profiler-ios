//
//  DeallocationExpectationReason.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Why an object was expected to deallocate.
public enum DeallocationExpectationReason: Sendable, Equatable, Codable, CustomStringConvertible {

    /// An explicit `expectDeallocation` or `DeinitTracker` call.
    case manual

    /// The view controller was popped, dismissed or removed from its parent.
    case viewControllerRemoved

    /// The view's controller was popped, dismissed or removed from its parent.
    case viewOfRemovedController

    /// The SwiftUI view that declared `detectLeaks(of:)` left the hierarchy.
    case swiftUIViewRemoved

    /// Human readable cause used in log messages.
    public var description: String {
        switch self {
        case .manual:
            return "the expectation"
        case .viewControllerRemoved:
            return "its view controller was removed"
        case .viewOfRemovedController:
            return "its owning view controller was removed"
        case .swiftUIViewRemoved:
            return "its SwiftUI view left the hierarchy"
        }
    }
}
