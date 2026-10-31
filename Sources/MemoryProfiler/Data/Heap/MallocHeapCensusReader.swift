//
//  MallocHeapCensusReader.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
internal import MemoryProfilerNative

/// Counts live instances per class by walking the malloc zones.
struct MallocHeapCensusReader: HeapCensusTaking {

    // MARK: - Properties

    let classifier: any TypeOriginClassifying
    let clock: any TimeProviding

    var isAvailable: Bool {
        mp_heap_is_available()
    }

    // MARK: - HeapCensusTaking

    func takeCensus(scope: TypeScope) throws -> HeapCensus {
        let catalog = RuntimeClassCatalog.current()
        guard catalog.count > 0 else { throw HeapCensusError.introspectionUnavailable }
        var counts = [UInt64](repeating: 0, count: catalog.count)
        var bytes = [UInt64](repeating: 0, count: catalog.count)
        let status = mp_heap_census(catalog.classAddresses, catalog.instanceSizes, catalog.count, &counts, &bytes)
        try status.validate()
        let entries = catalog.classAddresses.indices
            .filter { counts[$0] > 0 && isIncluded(catalog.classObject(atIndex: $0), in: scope) }
            .map { index in
                ClassCensusEntry(
                    typeName: String(reflecting: catalog.classObject(atIndex: index)),
                    instanceCount: Int(clamping: counts[index]),
                    totalBytes: bytes[index]
                )
            }
            .sorted { $0.totalBytes > $1.totalBytes }
        return HeapCensus(entries: entries, scope: scope, takenAt: clock.now)
    }

    // MARK: - Private Methods

    private func isIncluded(_ type: AnyClass, in scope: TypeScope) -> Bool {
        switch scope {
        case .allTypes:
            return true
        case .applicationTypes:
            return !classifier.isSystemClass(type)
        }
    }
}
