//
//  RetentionBlock.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A heap block found by the referrer scan.
public struct RetentionBlock: Sendable, Equatable {

    // MARK: - Properties

    /// Class of the block, or `nil` for raw heap blocks such as closure contexts and buffers.
    public let typeName: String?

    /// Hexadecimal address of the block.
    public let address: String

    /// Size of the block in bytes.
    public let size: UInt64

    // MARK: - Initialization

    /// Creates a block description.
    ///
    /// - Parameters:
    ///   - typeName: Class of the block, if known.
    ///   - address: Hexadecimal address.
    ///   - size: Size in bytes.
    public init(typeName: String?, address: String, size: UInt64) {
        self.typeName = typeName
        self.address = address
        self.size = size
    }
}
