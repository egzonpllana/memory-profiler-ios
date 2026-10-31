//
//  ByteFormatting.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Formats byte counts for log output.
enum ByteFormatting {

    /// Formats `bytes` with memory-style units, for example `1.2 GB`.
    static func string(from bytes: UInt64) -> String {
        Int64(clamping: bytes).formatted(.byteCount(style: .memory))
    }
}
