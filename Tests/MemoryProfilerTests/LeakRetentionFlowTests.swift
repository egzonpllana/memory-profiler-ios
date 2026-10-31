//
//  LeakRetentionFlowTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import XCTest
@testable import MemoryProfiler

final class LeakRetentionFlowTests: XCTestCase {

    private var configuration: LeakDetectionConfiguration {
        let diagnostics = LeakDiagnosticsConfiguration(retentionAnalysis: .referrerScan(maxDepth: 2))
        return LeakDetectionConfiguration(diagnostics: diagnostics)
    }

    private var analysis: RetentionAnalysis {
        let block = RetentionBlock(typeName: "MemoryProfilerTests.TrackedViewModel", address: "0x1", size: 32)
        let referrer = RetentionReferrer(block: block, fieldName: "onUpdate", offset: 24, depth: 1)
        let cycle = RetentionCycle(rootTypeName: "MemoryProfilerTests.TrackedViewModel", path: [referrer])
        return RetentionAnalysis(referrers: [], cycle: cycle, completeness: .complete)
    }

    func testRetentionAnalysisIsAttachedToReport() {
        let harness = LeakEngineHarness(configuration: configuration, analysis: analysis)
        let viewModel = TrackedViewModel()
        harness.expect(viewModel)
        harness.executor.runAll()

        XCTAssertTrue(harness.publisher.detectedLeaks.isEmpty)
        harness.scanner.complete()

        let cycle = harness.publisher.detectedLeaks.first?.retention?.cycle
        let expected = "MemoryProfilerTests.TrackedViewModel.onUpdate -> MemoryProfilerTests.TrackedViewModel"
        XCTAssertEqual(cycle?.description, expected)
        XCTAssertFalse(harness.scanner.ignoredBlocks.isEmpty)
    }

    func testObjectReleasedDuringAnalysisIsNotReported() {
        let harness = LeakEngineHarness(configuration: configuration, analysis: analysis)
        var viewModel: TrackedViewModel? = TrackedViewModel()
        if let viewModel {
            harness.expect(viewModel)
        }
        harness.executor.runAll()
        viewModel = nil
        harness.scanner.complete()

        XCTAssertTrue(harness.publisher.events.isEmpty)
    }
}
