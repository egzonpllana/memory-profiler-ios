//
//  ReferrerNode.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A visited block in the referrer search and the target it points to.
struct ReferrerNode {

    /// The block as a referrer.
    let description: ReferrerDescription

    /// The block it points to, one level closer to the root.
    let target: DisguisedAddress
}
