//
//  MemoryBallast.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Dirty memory that raises the physical footprint while it is alive.
final class MemoryBallast {

    private let buffer: UnsafeMutableRawPointer
    private let byteCount: Int

    init(megabytes: Int) {
        byteCount = megabytes * 1_024 * 1_024
        buffer = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: 16)
        buffer.initializeMemory(as: UInt8.self, repeating: 1, count: byteCount)
    }

    deinit {
        buffer.deallocate()
    }
}
