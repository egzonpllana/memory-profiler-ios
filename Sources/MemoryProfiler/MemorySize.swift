//
//  MemorySize.swift
//  MemoryProfiler
//
//  Created by Sevgjan Haxhija on 12.8.25.
//

import Foundation

/// A utility for working with memory sizes in a human-readable format.
///
/// This enum provides convenient static methods and properties for common memory sizes,
/// eliminating the need for repetitive calculations like `1024 * 1024 * 1024`.
///
/// Example usage:
/// ```swift
/// let threshold = MemorySize.GB(1)  // 1GB in bytes
/// let smallLimit = MemorySize.MB(100)  // 100MB in bytes
/// 
/// let usedMemory: UInt64 = 1073741824
/// print(usedMemory.toMB())  // "1024.00MB"
/// print(usedMemory.inMB)    // 1024
/// print(usedMemory.inGB)    // 1
/// ```
public enum MemorySize {
    
    // MARK: - Constants
    
    /// Bytes in 1 kilobyte
    public static let bytesPerKB: UInt64 = 1024
    
    /// Bytes in 1 megabyte
    public static let bytesPerMB: UInt64 = 1024 * 1024
    
    /// Bytes in 1 gigabyte
    public static let bytesPerGB: UInt64 = 1024 * 1024 * 1024
    
    // MARK: - Memory Size Creators
    
    /// Creates a memory size in bytes from kilobytes
    /// - Parameter kb: Size in kilobytes
    /// - Returns: Size in bytes
    public static func KB(_ kb: UInt64) -> UInt64 {
        return kb * bytesPerKB
    }
    
    /// Creates a memory size in bytes from megabytes
    /// - Parameter mb: Size in megabytes
    /// - Returns: Size in bytes
    public static func MB(_ mb: UInt64) -> UInt64 {
        return mb * bytesPerMB
    }
    
    /// Creates a memory size in bytes from gigabytes
    /// - Parameter gb: Size in gigabytes
    /// - Returns: Size in bytes
    public static func GB(_ gb: UInt64) -> UInt64 {
        return gb * bytesPerGB
    }
}

// MARK: - UInt64 Extensions

/// Extension to UInt64 for convenient memory size formatting
public extension UInt64 {
    
    /// Converts bytes to kilobytes with 2 decimal places
    /// - Returns: Formatted string (e.g., "1024.00KB")
    func toKB() -> String {
        let kb = Double(self) / Double(MemorySize.bytesPerKB)
        return String(format: "%.2fKB", kb)
    }
    
    /// Converts bytes to megabytes with 2 decimal places
    /// - Returns: Formatted string (e.g., "1024.00MB")
    func toMB() -> String {
        let mb = Double(self) / Double(MemorySize.bytesPerMB)
        return String(format: "%.2fMB", mb)
    }
    
    /// Converts bytes to gigabytes with 2 decimal places
    /// - Returns: Formatted string (e.g., "1.00GB")
    func toGB() -> String {
        let gb = Double(self) / Double(MemorySize.bytesPerGB)
        return String(format: "%.2fGB", gb)
    }
    
    /// Returns the raw megabyte value (truncated)
    var inMB: UInt64 {
        return self / MemorySize.bytesPerMB
    }
    
    /// Returns the raw gigabyte value (truncated)
    var inGB: UInt64 {
        return self / MemorySize.bytesPerGB
    }
    
    /// Returns the raw kilobyte value (truncated)
    var inKB: UInt64 {
        return self / MemorySize.bytesPerKB
    }
}
