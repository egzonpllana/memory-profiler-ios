//
//  StubUsageProbe.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

struct StubUsageProbe: ObjectUsageProbing {
    let isInUse: Bool

    func isObjectInUse(_ object: AnyObject) -> Bool {
        isInUse
    }
}
