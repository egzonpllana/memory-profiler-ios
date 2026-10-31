//
//  MemoryEventLogFormatterTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import XCTest
@testable import MemoryProfiler

final class MemoryEventLogFormatterTests: XCTestCase {

    private func report(retention: RetentionAnalysis?) -> LeakReport {
        let context = DeallocationExpectationContext(
            reason: .viewControllerRemoved,
            location: SourceLocation(fileID: "UIKit", line: 0, function: "viewDidDisappear(_:)"),
            expectedAt: Date(timeIntervalSince1970: 0),
            callStack: ["frame 0"]
        )
        return LeakReport(
            object: ObjectDescriptor(typeName: "App.DetailViewController", address: "0xabc", allocationSize: 1_024),
            expectation: context,
            detectedAt: Date(timeIntervalSince1970: 2),
            retention: retention
        )
    }

    func testLeakSummaryNamesAddressReasonAndCycle() {
        let block = RetentionBlock(typeName: "App.DetailViewController", address: "0xabc", size: 1_024)
        let referrer = RetentionReferrer(block: block, fieldName: "onClose", offset: 24, depth: 1)
        let cycle = RetentionCycle(rootTypeName: "App.DetailViewController", path: [referrer])
        let analysis = RetentionAnalysis(referrers: [], cycle: cycle, completeness: .complete)
        let records = MemoryEventLogFormatter.records(for: .leakDetected(report(retention: analysis)))
        let summary = records.first?.message ?? ""

        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records.first?.level, .error)
        XCTAssertTrue(summary.contains("App.DetailViewController 0xabc"))
        XCTAssertTrue(summary.contains("2.0s after its view controller was removed"))
        XCTAssertTrue(summary.contains("App.DetailViewController.onClose -> App.DetailViewController"))
        XCTAssertFalse(summary.contains("Expected at"))
    }

    func testResolutionIsInformational() {
        let resolution = LeakResolution(report: report(retention: nil), releasedAt: Date(timeIntervalSince1970: 9))
        let record = MemoryEventLogFormatter.records(for: .leakResolved(resolution)).first

        XCTAssertEqual(record?.level, .info)
        XCTAssertTrue(record?.message.contains("9.0s") ?? false)
    }
}
