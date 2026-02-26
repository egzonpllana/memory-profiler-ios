//
//  MemoryLeakInfo.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.7.25.
//

import Foundation

/// Information about a detected memory leak.
///
/// This struct provides details about potential memory leaks including
/// the type of object, count, memory size, and when it was detected.
public struct MemoryLeakInfo: Sendable {

    /// Type of object that might be leaking
    public let objectType: String

    /// Number of objects of this type
    public let objectCount: Int

    /// Estimated memory size used by these objects
    public let memorySize: UInt64

    /// When this leak was detected
    public let timestamp: Date

    /// Optional stack trace for debugging
    public let stackTrace: String?

    /// Creates memory leak information.
    ///
    /// - Parameters:
    ///   - objectType: Type of object that might be leaking
    ///   - objectCount: Number of objects detected
    ///   - memorySize: Estimated memory size in bytes
    ///   - stackTrace: Optional stack trace for debugging
    public init(objectType: String, objectCount: Int, memorySize: UInt64, stackTrace: String? = nil) {
        self.objectType = objectType
        self.objectCount = objectCount
        self.memorySize = memorySize
        self.stackTrace = stackTrace
        self.timestamp = Date()
    }
} 
