//
//  HeapReferenceScan.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
internal import MemoryProfilerNative

/// Runs one conservative heap walk for pointers to a set of targets.
enum HeapReferenceScan {

    // MARK: - Types

    private struct QueryBuffers {
        let targets: UnsafeBufferPointer<UInt>
        let ignoredBlocks: UnsafeBufferPointer<UInt>
        let references: UnsafeMutableBufferPointer<MPHeapReference>
        let headerWords: UnsafeMutableBufferPointer<UInt>
    }

    private struct QueryOutcome {
        let status: MPHeapStatus
        let hitCount: Int
    }

    // MARK: - Properties

    /// Maximum number of hits per walk.
    static let hitCapacity = 256

    /// Maximum number of targets per walk.
    static let targetCapacity = Int(MP_HEAP_MAX_REFERENCE_TARGETS)

    // MARK: - Public Methods

    /// Scans for pointers to `targets`, skipping `ignoredBlocks`.
    static func scan(targets: [UInt], ignoredBlocks: [UInt]) throws -> HeapReferenceScanResult {
        var references = [MPHeapReference](repeating: MPHeapReference(), count: hitCapacity)
        var headerWords = [UInt](repeating: 0, count: targets.count)
        let outcome = targets.withUnsafeBufferPointer { targetBuffer in
            ignoredBlocks.withUnsafeBufferPointer { ignoredBuffer in
                references.withUnsafeMutableBufferPointer { referenceBuffer in
                    headerWords.withUnsafeMutableBufferPointer { headerBuffer in
                        runQuery(QueryBuffers(
                            targets: targetBuffer,
                            ignoredBlocks: ignoredBuffer,
                            references: referenceBuffer,
                            headerWords: headerBuffer
                        ))
                    }
                }
            }
        }
        try outcome.status.validate()
        return makeResult(references: references.prefix(outcome.hitCount), targets: targets, headerWords: headerWords)
    }

    // MARK: - Private Methods

    private static func runQuery(_ buffers: QueryBuffers) -> QueryOutcome {
        var query = MPHeapReferenceQuery(
            targets: buffers.targets.baseAddress,
            targetCount: buffers.targets.count,
            ignoredBlocks: buffers.ignoredBlocks.baseAddress,
            ignoredCount: buffers.ignoredBlocks.count,
            references: buffers.references.baseAddress,
            referenceCapacity: buffers.references.count,
            referenceCount: 0,
            targetSecondWords: buffers.headerWords.baseAddress
        )
        let status = mp_heap_find_references(&query)
        return QueryOutcome(status: status, hitCount: query.referenceCount)
    }

    private static func makeResult(
        references: ArraySlice<MPHeapReference>,
        targets: [UInt],
        headerWords: [UInt]
    ) -> HeapReferenceScanResult {
        let hits = references.map { reference in
            HeapReferenceHit(
                block: DisguisedAddress(address: reference.blockAddress),
                blockSize: UInt64(reference.blockSize),
                blockClass: reference.blockClass,
                offset: reference.offset,
                target: DisguisedAddress(address: targets[reference.targetIndex])
            )
        }
        let sideTables = Set(headerWords.compactMap(SwiftSideTable.address(fromReferenceCountWord:)).map {
            DisguisedAddress(address: $0)
        })
        return HeapReferenceScanResult(hits: hits, sideTables: sideTables, isTruncated: references.count >= hitCapacity)
    }
}
