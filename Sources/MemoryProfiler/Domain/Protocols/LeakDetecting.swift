//
//  LeakDetecting.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Lifecycle leak detection engine.
protocol LeakDetecting: AnyObject, Sendable {

    /// Applies new leak detection settings to future expectations.
    func configure(_ configuration: LeakDetectionConfiguration)

    /// Registers an expectation that `object` deallocates within the grace period.
    func expectDeallocation(of object: AnyObject, request: DeallocationRequest)

    /// Counts `object` toward its type's live instance budget.
    func trackInstance(_ object: AnyObject, budget: Int, location: SourceLocation)

    /// Reports of objects that are currently leaked.
    func currentLeaks() -> [LeakReport]

    /// Drops every pending expectation and leaked entry.
    func reset()
}
