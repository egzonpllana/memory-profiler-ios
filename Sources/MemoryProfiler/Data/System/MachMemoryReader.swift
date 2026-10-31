//
//  MachMemoryReader.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
internal import MemoryProfilerNative

/// Reads the physical footprint, lifetime peak and remaining headroom with `TASK_VM_INFO`.
struct MachMemoryReader: MemoryReading {

    // MARK: - MemoryReading

    func readStats() -> MemoryStats? {
        var info = MPTaskMemoryInfo()
        guard mp_task_memory_info(&info) else { return nil }
        return MemoryStats(
            footprint: info.footprint,
            peakFootprint: max(info.peakFootprint, info.footprint),
            availableBeforeLimit: Self.availableBeforeLimit(info),
            physicalMemory: ProcessInfo.processInfo.physicalMemory
        )
    }

    // MARK: - Private Methods

    /// macOS has no per-process limit; zero means unknown on every platform.
    private static func availableBeforeLimit(_ info: MPTaskMemoryInfo) -> UInt64? {
        #if os(macOS)
        return nil
        #else
        return info.limitBytesRemaining > 0 ? info.limitBytesRemaining : nil
        #endif
    }
}
