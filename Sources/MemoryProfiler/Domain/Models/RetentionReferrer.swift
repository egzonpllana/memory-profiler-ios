//
//  RetentionReferrer.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A heap block that holds a pointer to a leaked object or to another referrer.
public struct RetentionReferrer: Sendable, Equatable {

    // MARK: - Properties

    /// The referring block.
    public let block: RetentionBlock

    /// Stored property that holds the pointer, when it can be resolved.
    public let fieldName: String?

    /// Byte offset of the pointer inside the block.
    public let offset: Int

    /// Distance from the leaked object: 1 for direct referrers.
    public let depth: Int

    /// `MyApp.Owner.onUpdate`, `MyApp.Owner+24`, or `heap block (48 bytes)`.
    public var displayName: String {
        guard let typeName = block.typeName else { return "heap block (\(block.size) bytes)" }
        guard let fieldName else { return "\(typeName)+\(offset)" }
        return "\(typeName).\(fieldName)"
    }

    // MARK: - Initialization

    /// Creates a referrer.
    ///
    /// - Parameters:
    ///   - block: The referring block.
    ///   - fieldName: Stored property holding the pointer, if resolved.
    ///   - offset: Byte offset of the pointer inside the block.
    ///   - depth: Distance from the leaked object.
    public init(block: RetentionBlock, fieldName: String?, offset: Int, depth: Int) {
        self.block = block
        self.fieldName = fieldName
        self.offset = offset
        self.depth = depth
    }
}
