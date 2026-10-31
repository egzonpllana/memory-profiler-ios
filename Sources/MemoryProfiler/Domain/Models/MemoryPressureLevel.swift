//
//  MemoryPressureLevel.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// System memory pressure reported by the kernel.
public enum MemoryPressureLevel: Sendable, Equatable {

    /// Pressure returned to normal.
    case normal

    /// The system is low on memory; release caches.
    case warning

    /// The system is critically low on memory; the process may be terminated.
    case critical
}
