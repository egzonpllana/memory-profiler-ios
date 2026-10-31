//
//  SystemTimeProvider.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// The wall clock.
struct SystemTimeProvider: TimeProviding {

    var now: Date {
        Date()
    }
}
