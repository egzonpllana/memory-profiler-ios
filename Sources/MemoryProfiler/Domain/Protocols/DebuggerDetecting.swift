//
//  DebuggerDetecting.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Detects an attached debugger.
protocol DebuggerDetecting: Sendable {

    /// Whether a debugger is attached to the process.
    var isDebuggerAttached: Bool { get }
}
