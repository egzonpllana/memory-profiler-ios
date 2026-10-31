//
//  MemoryLogCategory.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Area of the profiler a log message belongs to.
public enum MemoryLogCategory: String, Sendable, Equatable, CaseIterable {

    /// Start, stop, enable, disable and configuration changes.
    case lifecycle

    /// Footprint samples, thresholds and system memory pressure.
    case monitoring

    /// Leak detection, late releases and instance budgets.
    case leaks

    /// Heap census, allocation growth and retention analysis.
    case heap
}
