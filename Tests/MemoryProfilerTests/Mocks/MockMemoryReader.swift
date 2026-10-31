//
//  MockMemoryReader.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

final class MockMemoryReader: MemoryReading, @unchecked Sendable {
    private let stubbed = LockedState<MemoryStats?>(
        MemoryStats(
            footprint: 100_000_000,
            peakFootprint: 120_000_000,
            availableBeforeLimit: 900_000_000,
            physicalMemory: 4_000_000_000
        )
    )

    func stub(footprint: UInt64, availableBeforeLimit: UInt64?) {
        stubbed.withLock {
            $0 = MemoryStats(
                footprint: footprint,
                peakFootprint: footprint,
                availableBeforeLimit: availableBeforeLimit,
                physicalMemory: 4_000_000_000
            )
        }
    }

    func readStats() -> MemoryStats? {
        stubbed.value
    }
}
