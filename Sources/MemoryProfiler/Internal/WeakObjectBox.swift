//
//  WeakObjectBox.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A weak reference container.
///
/// A class rather than a struct so its heap address can be excluded from referrer scans:
/// Objective-C weak references store the raw object address.
/// `@unchecked Sendable` is sound because the reference is written once in `init` and weak
/// loads are atomic in the Swift runtime.
final class WeakObjectBox: @unchecked Sendable {

    // MARK: - Properties

    private(set) weak var object: AnyObject?

    /// Heap address of the box itself.
    var address: UInt {
        UInt(bitPattern: Unmanaged.passUnretained(self).toOpaque())
    }

    // MARK: - Initialization

    init(_ object: AnyObject) {
        self.object = object
    }
}
