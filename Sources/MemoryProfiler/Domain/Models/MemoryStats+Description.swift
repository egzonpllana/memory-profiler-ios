//
//  MemoryStats+Description.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

extension MemoryStats: CustomStringConvertible {

    /// `footprint 412 MB, peak 530 MB, limit 2.9 GB (14%)`.
    public var description: String {
        var parts = [
            "footprint \(ByteFormatting.string(from: footprint))",
            "peak \(ByteFormatting.string(from: peakFootprint))"
        ]
        if let limit, let usage = usageOfLimit {
            parts.append("limit \(ByteFormatting.string(from: limit)) (\(Int((usage * 100).rounded()))%)")
        } else {
            parts.append("physical memory \(ByteFormatting.string(from: physicalMemory))")
        }
        return parts.joined(separator: ", ")
    }
}
