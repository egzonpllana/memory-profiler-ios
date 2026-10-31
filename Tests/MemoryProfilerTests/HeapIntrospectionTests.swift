//
//  HeapIntrospectionTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import XCTest
@testable import MemoryProfiler

/// Walks the real heap of the test process. Heap introspection is compiled into debug builds only.
final class HeapIntrospectionTests: XCTestCase {

    private let classifier = RuntimeTypeOriginClassifier()
    private let census = MallocHeapCensusReader(classifier: RuntimeTypeOriginClassifier(), clock: SystemTimeProvider())

    override func setUpWithError() throws {
        try XCTSkipUnless(census.isAvailable, "Heap introspection is available in debug builds only.")
    }

    func testCensusCountsLiveInstances() throws {
        let subjects = (0..<250).map { _ in CensusSubject() }
        let snapshot = try census.takeCensus(scope: .applicationTypes)
        let entry = snapshot.entries.first { $0.typeName == "MemoryProfilerTests.CensusSubject" }

        XCTAssertEqual(entry?.instanceCount, 250)
        XCTAssertFalse(snapshot.entries.contains { $0.typeName == "NSObject" })
        withExtendedLifetime(subjects) {}
    }

    func testReferrerScanFindsClosureCycle() throws {
        let address = leakClosureCycle()
        let typeName = "MemoryProfilerTests.TrackedViewModel"
        let search = makeSearch(root: address, typeName: typeName, maxDepth: 2)
        let analysis = try search.run()

        XCTAssertEqual(analysis.cycle?.path.first?.fieldName, "onUpdate")
        XCTAssertEqual(
            analysis.cycle?.description,
            "MemoryProfilerTests.TrackedViewModel.onUpdate -> MemoryProfilerTests.TrackedViewModel"
        )
    }

    func testReferrerScanIgnoresSwiftWeakReferences() throws {
        let target = TrackedViewModel()
        let holder = WeakHolder(target: target)
        let address = DisguisedAddress(address: RuntimeObjectInspector().address(of: target))
        let search = makeSearch(root: address, typeName: "Target", maxDepth: 1)
        let analysis = try search.run()

        XCTAssertFalse(analysis.referrers.contains { $0.block.typeName == "MemoryProfilerTests.WeakHolder" })
        XCTAssertNil(analysis.cycle)
        withExtendedLifetime(holder) {}
    }

    // MARK: - Helpers

    private func makeSearch(root: DisguisedAddress, typeName: String, maxDepth: Int) -> ReferrerGraphSearch {
        ReferrerGraphSearch(
            root: root,
            rootTypeName: typeName,
            maxDepth: maxDepth,
            ignoredBlocks: [],
            classifier: classifier
        )
    }

    /// Creates a view model that retains itself through a stored closure and drops the last outside reference.
    private func leakClosureCycle() -> DisguisedAddress {
        let viewModel = TrackedViewModel()
        viewModel.bindStrongly()
        return DisguisedAddress(address: RuntimeObjectInspector().address(of: viewModel))
    }
}

private final class WeakHolder {
    weak var target: TrackedViewModel?

    init(target: TrackedViewModel) {
        self.target = target
    }
}
