//
//  HeapCensusTaking.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Counts live instances per class.
protocol HeapCensusTaking: Sendable {

    /// Whether heap introspection is available in this build and runtime.
    var isAvailable: Bool { get }

    /// Takes a census. Briefly pauses every allocating thread.
    func takeCensus(scope: TypeScope) throws -> HeapCensus
}
