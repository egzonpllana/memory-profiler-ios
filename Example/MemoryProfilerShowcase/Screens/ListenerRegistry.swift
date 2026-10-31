//
//  ListenerRegistry.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// A process-wide registry that never removes its listeners: the classic global retainer.
@MainActor
final class ListenerRegistry {

    static let shared = ListenerRegistry()

    private(set) var listeners: [AnyObject] = []

    func register(_ listener: AnyObject) {
        listeners.append(listener)
    }
}
