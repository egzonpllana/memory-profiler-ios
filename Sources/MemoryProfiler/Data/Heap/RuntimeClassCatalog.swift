//
//  RuntimeClassCatalog.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
import ObjectiveC

/// Snapshot of the classes registered with the Objective-C runtime, including native Swift classes.
struct RuntimeClassCatalog {

    // MARK: - Properties

    /// Class object addresses.
    let classAddresses: [UInt]

    /// `class_getInstanceSize` of each class, index aligned with `classAddresses`.
    let instanceSizes: [Int]

    private let indexByAddress: [UInt: Int]

    var count: Int {
        classAddresses.count
    }

    // MARK: - Initialization

    private init(classAddresses: [UInt]) {
        self.classAddresses = classAddresses
        self.instanceSizes = classAddresses.map { class_getInstanceSize(Self.classObject(at: $0)) }
        var indexByAddress: [UInt: Int] = [:]
        for index in classAddresses.indices {
            indexByAddress[classAddresses[index]] = index
        }
        self.indexByAddress = indexByAddress
    }

    /// Reads the current class list.
    static func current() -> RuntimeClassCatalog {
        var count: UInt32 = 0
        guard let list = objc_copyClassList(&count) else { return RuntimeClassCatalog(classAddresses: []) }
        defer { free(UnsafeMutableRawPointer(list)) }
        // Read raw words: subscripting the autoreleasing pointer retains each class, which
        // aborts for root classes that do not implement retain.
        let rawList = UnsafeRawPointer(list)
        let addresses = (0..<Int(count)).map {
            rawList.load(fromByteOffset: $0 * MemoryLayout<UInt>.stride, as: UInt.self)
        }
        return RuntimeClassCatalog(classAddresses: addresses)
    }

    // MARK: - Queries

    /// The class object at `index`.
    func classObject(atIndex index: Int) -> AnyClass {
        Self.classObject(at: classAddresses[index])
    }

    /// The class object for `address`, when it is a registered class.
    func classObject(forAddress address: UInt) -> AnyClass? {
        guard indexByAddress[address] != nil else { return nil }
        return Self.classObject(at: address)
    }

    /// Reinterprets a class address. Class objects are never retained, so this is safe for any registered class.
    static func classObject(at address: UInt) -> AnyClass {
        unsafeBitCast(address, to: AnyClass.self)
    }
}
