//
//  MemoryEventLogFormatter.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Turns events into log records.
enum MemoryEventLogFormatter {

    /// Log records for `event`, most important first.
    static func records(for event: MemoryProfilerEvent) -> [MemoryLogRecord] {
        switch event {
        case .leakDetected(let report):
            return records(leak: report)
        case .leakResolved(let resolution):
            return [record(resolved: resolution)]
        case .instanceBudgetExceeded(let violation):
            return [record(budget: violation)]
        case .allocationGrowthDetected(let suspect):
            return [record(growth: suspect)]
        case .thresholdExceeded(let stats):
            let message = "Footprint crossed the warning threshold: \(stats)."
            return [MemoryLogRecord(message: message, level: .warning, category: .monitoring)]
        case .thresholdRecovered(let stats):
            let message = "Footprint back below the warning threshold: \(stats)."
            return [MemoryLogRecord(message: message, level: .info, category: .monitoring)]
        case .systemMemoryPressure(let level):
            return [record(pressure: level)]
        }
    }

    // MARK: - Private Methods

    private static func records(leak report: LeakReport) -> [MemoryLogRecord] {
        let summary = MemoryLogRecord(message: LeakReportFormatter.summary(of: report), level: .error, category: .leaks)
        guard let stack = LeakReportFormatter.callStack(of: report) else { return [summary] }
        return [summary, MemoryLogRecord(message: stack, level: .debug, category: .leaks)]
    }

    private static func record(resolved resolution: LeakResolution) -> MemoryLogRecord {
        let object = resolution.report.object
        let retainedFor = String(format: "%.1f", resolution.retainedFor)
        let message = "Late release: \(object.typeName) \(object.address) deallocated \(retainedFor)s after "
            + "\(resolution.report.expectation.reason); it was not a permanent leak."
        return MemoryLogRecord(message: message, level: .info, category: .leaks)
    }

    private static func record(budget violation: InstanceBudgetViolation) -> MemoryLogRecord {
        let message = "Instance budget exceeded: \(violation.liveCount) live \(violation.typeName) instances, "
            + "budget \(violation.budget). Latest tracked at \(violation.location)."
        return MemoryLogRecord(message: message, level: .error, category: .leaks)
    }

    private static func record(growth suspect: AllocationGrowthSuspect) -> MemoryLogRecord {
        let counts = suspect.instanceCounts.map(String.init).joined(separator: " -> ")
        let message = "Allocation growth: \(suspect.typeName) instances \(counts), "
            + "holding \(ByteFormatting.string(from: suspect.totalBytes))."
        return MemoryLogRecord(message: message, level: .warning, category: .heap)
    }

    private static func record(pressure level: MemoryPressureLevel) -> MemoryLogRecord {
        switch level {
        case .normal:
            return MemoryLogRecord(message: "System memory pressure: normal.", level: .info, category: .monitoring)
        case .warning:
            return MemoryLogRecord(message: "System memory pressure: warning.", level: .warning, category: .monitoring)
        case .critical:
            return MemoryLogRecord(message: "System memory pressure: critical.", level: .error, category: .monitoring)
        }
    }
}
