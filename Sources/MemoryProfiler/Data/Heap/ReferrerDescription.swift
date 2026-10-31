//
//  ReferrerDescription.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A referrer and the origin of its block's class.
struct ReferrerDescription {

    /// The named referrer.
    let referrer: RetentionReferrer

    /// Whether the block belongs to the app, a framework, or nothing known.
    let origin: ReferrerOrigin
}
