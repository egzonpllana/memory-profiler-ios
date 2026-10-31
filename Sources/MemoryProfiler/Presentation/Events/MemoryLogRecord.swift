//
//  MemoryLogRecord.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A formatted log line for an event.
struct MemoryLogRecord: Equatable {
    let message: String
    let level: MemoryLogLevel
    let category: MemoryLogCategory
}
