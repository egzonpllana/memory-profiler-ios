//
//  EventRowFactory.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
import MemoryProfiler

/// Turns profiler events into rows for the event log.
enum EventRowFactory {

    // MARK: - Public Methods

    static func row(for event: MemoryProfilerEvent) -> EventRow {
        switch event {
        case .leakDetected(let report):
            return row(.leak, "Leak: \(shortName(report.object.typeName))", detail(of: report))
        case .leakResolved(let resolution):
            return lateReleaseRow(for: resolution)
        case .instanceBudgetExceeded(let violation):
            let detail = "\(violation.liveCount) live instances, budget \(violation.budget). "
                + "Tracked at \(violation.location)."
            return row(.budget, "Budget exceeded: \(shortName(violation.typeName))", detail)
        case .allocationGrowthDetected(let suspect):
            let counts = suspect.instanceCounts.map(String.init).joined(separator: " -> ")
            return row(.growth, "Growing: \(shortName(suspect.typeName))", "Live instances \(counts)")
        case .thresholdExceeded(let stats):
            return row(.threshold, "Footprint above threshold", stats.description)
        case .thresholdRecovered(let stats):
            return row(.threshold, "Footprint back below threshold", stats.description)
        case .systemMemoryPressure(let level):
            return row(.pressure, "System memory pressure", "\(level)")
        }
    }

    // MARK: - Private Methods

    private static func lateReleaseRow(for resolution: LeakResolution) -> EventRow {
        let seconds = String(format: "%.1f", resolution.retainedFor)
        let detail = "Released \(seconds)s after it was expected to deallocate. Not a permanent leak."
        return row(.lateRelease, "Late release: \(shortName(resolution.report.object.typeName))", detail)
    }

    private static func row(_ kind: EventKind, _ title: String, _ detail: String) -> EventRow {
        EventRow(kind: kind, title: title, detail: detail, receivedAt: Date())
    }

    /// Drops this app's module prefix so rows stay readable on a phone.
    private static func shortName(_ text: String) -> String {
        text.replacingOccurrences(of: "MemoryProfilerShowcase.", with: "")
    }

    private static func detail(of report: LeakReport) -> String {
        let overdue = String(format: "%.1f", report.overdueInterval)
        var lines = [
            "\(report.object.address), \(report.object.allocationSize) bytes",
            "Alive \(overdue)s after \(report.expectation.reason)."
        ]
        if let cycle = report.retention?.cycle {
            lines.append("Retain cycle: " + shortName(cycle.description))
        } else if let referrers = report.retention?.referrers.filter({ $0.depth == 1 }), !referrers.isEmpty {
            let names = referrers.prefix(3).map(\.displayName).joined(separator: ", ")
            lines.append("Referenced by: " + shortName(names))
        }
        return lines.joined(separator: "\n")
    }
}
