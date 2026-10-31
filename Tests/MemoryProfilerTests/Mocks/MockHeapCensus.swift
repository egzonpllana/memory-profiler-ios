//
//  MockHeapCensus.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
@testable import MemoryProfiler

final class MockHeapCensus: HeapCensusTaking, @unchecked Sendable {
    var isAvailable = true
    var stubbedEntries: [ClassCensusEntry] = []

    func takeCensus(scope: TypeScope) throws -> HeapCensus {
        guard isAvailable else { throw HeapCensusError.introspectionUnavailable }
        return HeapCensus(entries: stubbedEntries, scope: scope, takenAt: Date())
    }
}
