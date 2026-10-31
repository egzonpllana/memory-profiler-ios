//
//  AutomaticTrackingTarget.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Objects the profiler tracks without any call from the app.
public enum AutomaticTrackingTarget: Sendable, Hashable, CaseIterable {

    /// View controllers that are popped, dismissed or removed from their parent (UIKit).
    case viewControllers

    /// The root view of each removed view controller (UIKit).
    case views
}
