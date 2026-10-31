//
//  MemoryEventBroadcaster.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Delivers events, in order, to internal observers, handlers and async streams on a serial queue.
final class MemoryEventBroadcaster: MemoryEventPublishing {

    // MARK: - Types

    private struct Subscribers {
        var handlers: [UUID: @Sendable (MemoryProfilerEvent) -> Void] = [:]
        var continuations: [UUID: AsyncStream<MemoryProfilerEvent>.Continuation] = [:]
    }

    // MARK: - Properties

    private static let streamBufferSize = 256

    private let queue = DispatchQueue(label: "com.egzonpllana.MemoryProfiler.events", qos: .utility)
    private let subscribers = LockedState(Subscribers())
    private let observers: [any MemoryEventObserving]

    // MARK: - Initialization

    init(observers: [any MemoryEventObserving]) {
        self.observers = observers
    }

    // MARK: - MemoryEventPublishing

    /// Subscribers are captured now, so an event reaches exactly those registered when it was published.
    func publish(_ event: MemoryProfilerEvent) {
        let current = subscribers.value
        queue.async { [observers] in
            for observer in observers {
                observer.observe(event)
            }
            for handler in current.handlers.values {
                handler(event)
            }
            for continuation in current.continuations.values {
                continuation.yield(event)
            }
        }
    }

    // MARK: - Subscriptions

    /// A new stream that receives every event published after this call.
    func makeStream() -> AsyncStream<MemoryProfilerEvent> {
        let (stream, continuation) = AsyncStream.makeStream(
            of: MemoryProfilerEvent.self,
            bufferingPolicy: .bufferingNewest(Self.streamBufferSize)
        )
        let identifier = UUID()
        subscribers.withLock { $0.continuations[identifier] = continuation }
        continuation.onTermination = { [subscribers] _ in
            subscribers.withLock { $0.continuations[identifier] = nil }
        }
        return stream
    }

    /// Registers a handler until the returned subscription is cancelled.
    @discardableResult
    func addHandler(_ handler: @escaping @Sendable (MemoryProfilerEvent) -> Void) -> EventSubscription {
        let identifier = UUID()
        subscribers.withLock { $0.handlers[identifier] = handler }
        return EventSubscription { [subscribers] in
            subscribers.withLock { $0.handlers[identifier] = nil }
        }
    }
}
