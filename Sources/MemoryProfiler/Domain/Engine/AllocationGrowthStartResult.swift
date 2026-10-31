//
//  AllocationGrowthStartResult.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Outcome of starting allocation growth sampling.
enum AllocationGrowthStartResult: Equatable {

    /// Growth detection is disabled in the configuration.
    case disabled

    /// Sampling started.
    case started

    /// Growth detection is enabled but heap introspection is not available in this build.
    case unavailable
}
