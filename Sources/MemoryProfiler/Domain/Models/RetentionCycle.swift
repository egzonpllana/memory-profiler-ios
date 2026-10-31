//
//  RetentionCycle.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A chain of strong-looking references that leads from a leaked object back to itself.
public struct RetentionCycle: Sendable, Equatable, CustomStringConvertible {

    // MARK: - Properties

    /// Type name of the leaked object.
    public let rootTypeName: String

    /// Referrers in order, starting with the leaked object's own field.
    public let path: [RetentionReferrer]

    /// `MyApp.Owner.onUpdate -> heap block 48 bytes -> MyApp.Owner`.
    public var description: String {
        (path.map(\.displayName) + [rootTypeName]).joined(separator: " -> ")
    }

    // MARK: - Initialization

    /// Creates a retention cycle.
    ///
    /// - Parameters:
    ///   - rootTypeName: Type name of the leaked object.
    ///   - path: Referrers in order, starting with the leaked object's own field.
    public init(rootTypeName: String, path: [RetentionReferrer]) {
        self.rootTypeName = rootTypeName
        self.path = path
    }
}
