//
//  TimeProviding.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Source of the current time.
protocol TimeProviding: Sendable {

    /// The current date.
    var now: Date { get }
}
