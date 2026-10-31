//
//  RuntimeObjectInspector.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Reads identity details of live objects from the Swift and Objective-C runtimes.
struct RuntimeObjectInspector: ObjectInspecting {

    // MARK: - Properties

    private static let maximumStackDepth = 48

    // MARK: - ObjectInspecting

    func typeName(of object: AnyObject) -> String {
        String(reflecting: type(of: object))
    }

    func address(of object: AnyObject) -> UInt {
        UInt(bitPattern: Unmanaged.passUnretained(object).toOpaque())
    }

    /// `allocationSize` is zero for objects that are not heap allocated, such as tagged pointers.
    func describe(_ object: AnyObject) -> ObjectDescriptor {
        let pointer = Unmanaged.passUnretained(object).toOpaque()
        return ObjectDescriptor(
            typeName: typeName(of: object),
            address: ObjectDescriptor.hexAddress(UInt(bitPattern: pointer)),
            allocationSize: UInt64(malloc_size(pointer))
        )
    }

    func callStack() -> [String] {
        let frames = Thread.callStackSymbols.drop { $0.contains("MemoryProfiler") }
        return Array(frames.prefix(Self.maximumStackDepth))
    }
}
