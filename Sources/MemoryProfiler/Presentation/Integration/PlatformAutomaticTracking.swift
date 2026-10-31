//
//  PlatformAutomaticTracking.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Picks the automatic tracking hooks available on the current platform.
enum PlatformAutomaticTracking {

    /// UIKit view controller tracking where UIKit exists; a no-op elsewhere.
    static func make() -> any AutomaticTrackingInstalling {
        #if canImport(UIKit) && !os(watchOS)
        return ViewControllerLeakWatcher.shared
        #else
        return NoAutomaticTracking()
        #endif
    }
}
