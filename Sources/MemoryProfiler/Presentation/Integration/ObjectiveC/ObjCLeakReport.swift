//
//  ObjCLeakReport.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Objective-C view of a `LeakReport`.
@objc(MPLeakReport)
public final class ObjCLeakReport: NSObject, Sendable {

    // MARK: - Properties

    /// Fully qualified type name of the leaked object.
    @objc public let typeName: String

    /// Hexadecimal address; paste it into the Debug Memory Graph filter.
    @objc public let address: String

    /// Heap allocation size in bytes.
    @objc public let allocationSize: UInt64

    /// Why the object was expected to deallocate.
    @objc public let reason: String

    /// The full log line.
    @objc public let summary: String

    // MARK: - Initialization

    /// Reports are created by MemoryProfiler. Calling `-init` or `+new` from Objective-C returns an empty
    /// report instead of trapping, as Swift classes without an `init()` override do.
    @available(*, unavailable, message: "Leak reports are created by MemoryProfiler.")
    override public init() {
        typeName = ""
        address = ""
        allocationSize = 0
        reason = ""
        summary = ""
        super.init()
    }

    init(report: LeakReport) {
        typeName = report.object.typeName
        address = report.object.address
        allocationSize = report.object.allocationSize
        reason = report.expectation.reason.description
        summary = LeakReportFormatter.summary(of: report)
        super.init()
    }
}
