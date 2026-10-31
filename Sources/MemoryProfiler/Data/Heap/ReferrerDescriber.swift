//
//  ReferrerDescriber.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Turns raw heap hits into named referrers.
struct ReferrerDescriber {

    // MARK: - Properties

    let catalog: RuntimeClassCatalog
    let classifier: any TypeOriginClassifying

    // MARK: - Public Methods

    /// A described referrer for `hit` at `depth`.
    func describe(_ hit: HeapReferenceHit, depth: Int) -> ReferrerDescription {
        let blockType: AnyClass? = catalog.classObject(forAddress: hit.blockClass)
        let block = RetentionBlock(
            typeName: blockType.map { String(reflecting: $0) },
            address: ObjectDescriptor.hexAddress(hit.block.address),
            size: hit.blockSize
        )
        let fieldName = blockType.flatMap { IvarNameResolver.fieldName(in: $0, containingOffset: hit.offset) }
        let referrer = RetentionReferrer(block: block, fieldName: fieldName, offset: hit.offset, depth: depth)
        return ReferrerDescription(referrer: referrer, origin: origin(of: blockType))
    }

    // MARK: - Private Methods

    private func origin(of blockType: AnyClass?) -> ReferrerOrigin {
        guard let blockType else { return .unknown }
        return classifier.isSystemClass(blockType) ? .system : .application
    }
}
