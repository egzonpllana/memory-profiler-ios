//
//  EventFeed.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
import MemoryProfiler

/// Collects profiler events from the `events` stream for the event log.
@MainActor
final class EventFeed {

    // MARK: - Properties

    static let shared = EventFeed()

    private(set) var rows: [EventRow] = []
    private var observers: [@MainActor () -> Void] = []
    private var listeningTask: Task<Void, Never>?

    // MARK: - Public Methods

    /// Consumes `profiler.events` for the lifetime of the app.
    func startListening(to profiler: any MemoryProfilerServicing) {
        guard listeningTask == nil else { return }
        let events = profiler.events
        listeningTask = Task { [weak self] in
            for await event in events {
                self?.append(event)
            }
        }
    }

    func addObserver(_ observer: @escaping @MainActor () -> Void) {
        observers.append(observer)
    }

    func clear() {
        rows.removeAll()
        notifyObservers()
    }

    func count(of kind: EventKind) -> Int {
        rows.filter { $0.kind == kind }.count
    }

    // MARK: - Private Methods

    private func append(_ event: MemoryProfilerEvent) {
        let row = EventRowFactory.row(for: event)
        rows.insert(row, at: 0)
        let flatDetail = row.detail.replacingOccurrences(of: "\n", with: " | ")
        Transcript.write("EVENT [\(row.kind.rawValue)] \(row.title) | \(flatDetail)")
        notifyObservers()
    }

    private func notifyObservers() {
        for observer in observers {
            observer()
        }
    }
}
