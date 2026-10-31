//
//  MemoryProfilerService+Monitoring.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

extension MemoryProfilerService {

    public var events: AsyncStream<MemoryProfilerEvent> {
        components.broadcaster.makeStream()
    }

    @discardableResult
    public func addEventHandler(_ handler: @escaping @Sendable (MemoryProfilerEvent) -> Void) -> EventSubscription {
        components.broadcaster.addHandler(handler)
    }

    public func currentStats() -> MemoryStats? {
        guard isActive else { return nil }
        return components.memoryReader.readStats()
    }

    public func logMemoryUsage(context: String) {
        guard let stats = currentStats() else { return }
        let suffix = context.isEmpty ? "" : " [\(context)]"
        components.logger.log("Memory: \(stats)\(suffix)", level: .info, category: .monitoring)
    }

    public func heapCensus(limit: Int, scope: TypeScope) throws -> HeapCensus {
        guard isActive else { throw HeapCensusError.profilerInactive }
        return try components.heapCensus.takeCensus(scope: scope).limited(to: limit)
    }
}
