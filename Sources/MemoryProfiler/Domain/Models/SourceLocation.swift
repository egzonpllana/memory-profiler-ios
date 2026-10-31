//
//  SourceLocation.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Source position of a profiler call.
public struct SourceLocation: Sendable, Equatable, Codable, CustomStringConvertible {

    // MARK: - Properties

    /// File identifier in `Module/File.swift` form.
    public let fileID: String

    /// Line number.
    public let line: Int

    /// Enclosing function.
    public let function: String

    /// `File.swift:42`.
    public var description: String {
        "\(fileID):\(line)"
    }

    // MARK: - Initialization

    /// Creates a source location.
    ///
    /// - Parameters:
    ///   - fileID: File identifier, usually `#fileID`.
    ///   - line: Line number, usually `#line`.
    ///   - function: Enclosing function, usually `#function`.
    public init(fileID: String, line: Int, function: String) {
        self.fileID = fileID
        self.line = line
        self.function = function
    }
}
