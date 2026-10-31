//
//  MPHeapStatus+Validation.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
internal import MemoryProfilerNative

extension MPHeapStatus {

    /// Throws the matching `HeapCensusError` for any status other than success.
    func validate() throws {
        switch self {
        case .success:
            return
        case .unavailable:
            throw HeapCensusError.introspectionUnavailable
        case .outOfMemory:
            throw HeapCensusError.outOfMemory
        case .zoneEnumerationFailed, .invalidArgument:
            throw HeapCensusError.zoneEnumerationFailed
        }
    }
}
