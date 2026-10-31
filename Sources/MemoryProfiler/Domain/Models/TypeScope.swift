//
//  TypeScope.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Which classes a heap census or growth analysis considers.
public enum TypeScope: Sendable, Equatable {

    /// Classes defined outside Apple system frameworks and the Swift standard library.
    case applicationTypes

    /// Every class known to the Objective-C runtime.
    case allTypes
}
