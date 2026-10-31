//
//  ReferrerOrigin.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Where the class of a referring block comes from.
enum ReferrerOrigin {

    /// A class defined by the app.
    case application

    /// A class defined by an Apple framework or the Swift runtime.
    case system

    /// A raw heap block without a known class, such as a closure context or a buffer.
    case unknown
}
