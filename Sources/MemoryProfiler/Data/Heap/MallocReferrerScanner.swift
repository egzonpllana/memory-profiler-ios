//
//  MallocReferrerScanner.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Runs the referrer search on a background queue.
final class MallocReferrerScanner: ReferrerScanning {

    // MARK: - Properties

    private let queue = DispatchQueue(label: "com.egzonpllana.MemoryProfiler.retention", qos: .utility)
    private let logger: any MemoryLogging
    private let classifier: any TypeOriginClassifying

    // MARK: - Initialization

    init(logger: any MemoryLogging, classifier: any TypeOriginClassifying) {
        self.logger = logger
        self.classifier = classifier
    }

    // MARK: - ReferrerScanning

    func analyzeRetention(
        of root: DisguisedAddress,
        rootTypeName: String,
        maxDepth: Int,
        ignoredBlocks: [UInt],
        completion: @escaping @Sendable (RetentionAnalysis?) -> Void
    ) {
        let search = ReferrerGraphSearch(
            root: root,
            rootTypeName: rootTypeName,
            maxDepth: maxDepth,
            ignoredBlocks: ignoredBlocks,
            classifier: classifier
        )
        queue.async { [logger] in
            do {
                completion(try search.run())
            } catch {
                logger.log("Retention analysis skipped: \(error)", level: .warning, category: .heap)
                completion(nil)
            }
        }
    }
}
