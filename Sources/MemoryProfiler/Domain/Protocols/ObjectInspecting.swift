//
//  ObjectInspecting.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Reads identity details of live objects.
protocol ObjectInspecting: Sendable {

    /// Fully qualified type name.
    func typeName(of object: AnyObject) -> String

    /// Heap address.
    func address(of object: AnyObject) -> UInt

    /// Type name, formatted address and allocation size.
    func describe(_ object: AnyObject) -> ObjectDescriptor

    /// The current call stack, without profiler frames where possible.
    func callStack() -> [String]
}
