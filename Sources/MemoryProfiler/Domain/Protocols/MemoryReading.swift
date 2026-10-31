//
//  MemoryReading.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Reads the footprint of the current process.
protocol MemoryReading: Sendable {

    /// The current footprint sample, or `nil` when the kernel call fails.
    func readStats() -> MemoryStats?
}
