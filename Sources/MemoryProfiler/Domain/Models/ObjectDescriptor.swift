//
//  ObjectDescriptor.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Identity of a tracked object, captured while it was alive.
public struct ObjectDescriptor: Sendable, Equatable, Codable {

    // MARK: - Properties

    /// Fully qualified type name, for example `MyApp.DetailViewModel`.
    public let typeName: String

    /// Hexadecimal address, for example `0x600003d04e80`. Paste it into the Debug Memory Graph filter.
    public let address: String

    /// Size of the object's heap allocation in bytes.
    public let allocationSize: UInt64

    // MARK: - Initialization

    /// Creates an object descriptor.
    ///
    /// - Parameters:
    ///   - typeName: Fully qualified type name.
    ///   - address: Hexadecimal address.
    ///   - allocationSize: Heap allocation size in bytes.
    public init(typeName: String, address: String, allocationSize: UInt64) {
        self.typeName = typeName
        self.address = address
        self.allocationSize = allocationSize
    }

    /// Formats an address as `0x…`.
    static func hexAddress(_ address: UInt) -> String {
        "0x" + String(address, radix: 16)
    }
}
