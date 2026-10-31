//
//  IvarNameResolver.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
import ObjectiveC

/// Maps a byte offset inside an object to the stored property that contains it.
enum IvarNameResolver {

    // MARK: - Properties

    private static let isaName = "isa"

    // MARK: - Public Methods

    /// The instance variable with the largest offset not after `offset`, searching from the
    /// most derived class up. Works for Objective-C classes and native Swift classes.
    ///
    /// Returns `nil` when the offset lies past the end of the class that declares the closest
    /// instance variable: such pointers live in tail storage, like array elements or block captures.
    static func fieldName(in type: AnyClass, containingOffset offset: Int) -> String? {
        var current: AnyClass? = type
        while let candidate = current {
            if let name = fieldName(declaredIn: candidate, containingOffset: offset) {
                let isInsideDeclaringClass = offset < class_getInstanceSize(candidate)
                return isInsideDeclaringClass && name != isaName ? name : nil
            }
            current = class_getSuperclass(candidate)
        }
        return nil
    }

    // MARK: - Private Methods

    private static func fieldName(declaredIn type: AnyClass, containingOffset offset: Int) -> String? {
        var count: UInt32 = 0
        guard let ivars = class_copyIvarList(type, &count) else { return nil }
        defer { free(ivars) }
        let candidates = (0..<Int(count)).map { ivars[$0] }.filter { ivar_getOffset($0) <= offset }
        guard let closest = candidates.max(by: { ivar_getOffset($0) < ivar_getOffset($1) }),
              let name = ivar_getName(closest) else { return nil }
        return String(cString: name)
    }
}
