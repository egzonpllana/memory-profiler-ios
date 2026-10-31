//
//  LeakReportFormatter.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Formats leak reports for logs and alerts.
enum LeakReportFormatter {

    // MARK: - Properties

    private static let referrerPreviewLimit = 8

    // MARK: - Public Methods

    /// One-line summary with the Debug Memory Graph hint.
    static func summary(of report: LeakReport) -> String {
        let object = report.object
        let overdue = String(format: "%.1f", report.overdueInterval)
        var message = "Leak: \(object.typeName) \(object.address) (\(object.allocationSize) bytes) is still alive "
            + "\(overdue)s after \(report.expectation.reason)."
        if report.expectation.location.line > 0 {
            message += " Expected at \(report.expectation.location) in \(report.expectation.location.function)."
        }
        message += " Filter the Debug Memory Graph by \(object.address)."
        return message + retentionSummary(of: report.retention)
    }

    /// The captured call stack as one block, or `nil` when none was captured.
    static func callStack(of report: LeakReport) -> String? {
        guard !report.expectation.callStack.isEmpty else { return nil }
        let header = "Call stack of the expectation for \(report.object.typeName) \(report.object.address):"
        return ([header] + report.expectation.callStack).joined(separator: "\n")
    }

    // MARK: - Private Methods

    private static func retentionSummary(of retention: RetentionAnalysis?) -> String {
        guard let retention else { return "" }
        if let cycle = retention.cycle {
            return " Possible retain cycle (conservative scan): \(cycle)."
        }
        guard !retention.referrers.isEmpty else {
            return " No heap referrers found; it may be retained by a global, a stack frame or a cache outside malloc."
        }
        let names = retention.referrers.filter { $0.depth == 1 }.prefix(referrerPreviewLimit).map(\.displayName)
        return " Referenced by (conservative scan): \(names.joined(separator: ", "))."
    }
}
