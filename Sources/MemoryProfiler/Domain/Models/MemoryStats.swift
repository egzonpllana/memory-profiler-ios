//
//  MemoryStats.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A footprint sample of the current process.
public struct MemoryStats: Sendable, Equatable, Codable {

    // MARK: - Properties

    /// Physical footprint in bytes: the value Xcode's memory gauge and jetsam use.
    public let footprint: UInt64

    /// Highest footprint of the process lifetime, as tracked by the kernel.
    public let peakFootprint: UInt64

    /// Bytes left before the process memory limit. `nil` on macOS or when unknown.
    public let availableBeforeLimit: UInt64?

    /// Physical memory of the device.
    public let physicalMemory: UInt64

    /// When the sample was taken.
    public let timestamp: Date

    /// The process memory limit (footprint plus available memory). `nil` when unknown.
    public var limit: UInt64? {
        availableBeforeLimit.map { footprint.saturatingAdding($0) }
    }

    /// Footprint as a fraction (0...1) of the memory limit. `nil` when the limit is unknown.
    public var usageOfLimit: Double? {
        guard let limit, limit > 0 else { return nil }
        return Double(footprint) / Double(limit)
    }

    // MARK: - Initialization

    /// Creates a footprint sample.
    ///
    /// - Parameters:
    ///   - footprint: Physical footprint in bytes.
    ///   - peakFootprint: Lifetime peak footprint in bytes.
    ///   - availableBeforeLimit: Bytes left before the memory limit, if known.
    ///   - physicalMemory: Physical memory of the device in bytes.
    ///   - timestamp: Sample time. Defaults to now.
    public init(
        footprint: UInt64,
        peakFootprint: UInt64,
        availableBeforeLimit: UInt64?,
        physicalMemory: UInt64,
        timestamp: Date = Date()
    ) {
        self.footprint = footprint
        self.peakFootprint = peakFootprint
        self.availableBeforeLimit = availableBeforeLimit
        self.physicalMemory = physicalMemory
        self.timestamp = timestamp
    }
}
