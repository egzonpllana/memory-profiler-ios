//
//  ThresholdTransition.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A change of the footprint relative to the warning threshold.
enum ThresholdTransition: Equatable {

    /// The footprint reached the threshold.
    case exceeded

    /// The footprint fell below the recovery level.
    case recovered
}
