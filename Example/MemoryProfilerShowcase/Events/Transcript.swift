//
//  Transcript.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Writes lines to stderr so `simctl launch --console-pty` shows what the showcase observed.
enum Transcript {

    static func write(_ line: String) {
        FileHandle.standardError.write(Data((line + "\n").utf8))
    }
}
