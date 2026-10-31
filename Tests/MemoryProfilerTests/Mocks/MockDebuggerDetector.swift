//
//  MockDebuggerDetector.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

struct MockDebuggerDetector: DebuggerDetecting {
    var isDebuggerAttached = false
}
