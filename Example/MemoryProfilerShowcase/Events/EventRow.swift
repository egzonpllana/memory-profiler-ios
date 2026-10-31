//
//  EventRow.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A profiler event prepared for display.
struct EventRow {
    let kind: EventKind
    let title: String
    let detail: String
    let receivedAt: Date
}
