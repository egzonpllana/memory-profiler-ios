//
//  MainQueueDetector.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Tells whether the current code runs on the main dispatch queue.
///
/// `Thread.isMainThread` is not enough before entering the main actor: a block that another
/// queue runs synchronously on the main thread is not on the main queue, and the Swift 6
/// isolation check traps there.
enum MainQueueDetector {

    // MARK: - Properties

    private static let key: DispatchSpecificKey<Bool> = {
        let key = DispatchSpecificKey<Bool>()
        DispatchQueue.main.setSpecific(key: key, value: true)
        return key
    }()

    /// Whether the current code runs on the main queue.
    static var isOnMainQueue: Bool {
        DispatchQueue.getSpecific(key: key) == true
    }
}
