//
//  LeakDetectionExempt.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Marker for classes that are intentionally kept alive after removal, such as view controllers
/// cached by a coordinator or pages held by a page view controller data source.
///
/// Conforming objects are never reported by `expectDeallocation` or automatic tracking.
public protocol LeakDetectionExempt: AnyObject {}
