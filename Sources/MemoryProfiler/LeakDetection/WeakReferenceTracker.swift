//
//  WeakReferenceTracker.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

/// Detects potential memory leaks by holding weak references to tracked objects.
///
/// When an object survives past its expected lifetime (scope-bound or time-bound),
/// it is reported as a potential leak. All operations are thread-safe via `UnfairLock`.
public final class WeakReferenceTracker: LeakDetecting {

    // MARK: - Properties

    private let lock = UnfairLock()
    private var entries: [ObjectIdentifier: TrackedEntry] = [:]
    private let scopeGracePeriod: TimeInterval

    // MARK: - Initialization

    /// Creates a weak reference tracker.
    ///
    /// - Parameter scopeGracePeriod: Grace period in seconds
    ///   before a scope-bound object is considered leaked. Default is 3 seconds.
    public init(scopeGracePeriod: TimeInterval = 3.0) {
        self.scopeGracePeriod = scopeGracePeriod
    }

    // MARK: - LeakDetecting

    public func trackObject(
        _ object: AnyObject,
        expectedLifetime: ObjectLifetime
    ) {
        let identifier = ObjectIdentifier(object)
        let typeName = String(describing: type(of: object))

        let entry = TrackedEntry(
            reference: object,
            typeName: typeName,
            lifetime: expectedLifetime,
            trackedAt: Date()
        )

        lock.withLock { entries[identifier] = entry }
    }

    public func checkForLeaks() -> [MemoryLeakInfo] {
        lock.withLock {
            purgeReleasedEntriesUnsafe()
            return entries.values.compactMap(leakInfoIfOverdue)
        }
    }

    @discardableResult
    public func removeTracking(for object: AnyObject) -> Bool {
        let identifier = ObjectIdentifier(object)
        return lock.withLock {
            entries.removeValue(forKey: identifier) != nil
        }
    }

    public func purgeReleasedObjects() {
        lock.withLock { purgeReleasedEntriesUnsafe() }
    }

    // MARK: - Private Methods

    /// Removes entries whose tracked object has been deallocated.
    /// Must be called while holding `lock`.
    private func purgeReleasedEntriesUnsafe() {
        entries = entries.filter { $0.value.reference != nil }
    }

    /// Returns leak info if the entry's object survived past its lifetime.
    private func leakInfoIfOverdue(_ entry: TrackedEntry) -> MemoryLeakInfo? {
        guard entry.reference != nil else { return nil }

        let elapsed = Date().timeIntervalSince(entry.trackedAt)
        let threshold: TimeInterval

        switch entry.lifetime {
        case .scopeBound:
            threshold = scopeGracePeriod
        case .timeBound(let seconds):
            threshold = seconds
        }

        guard elapsed > threshold else { return nil }

        return MemoryLeakInfo(
            objectType: entry.typeName,
            objectCount: 1,
            memorySize: 0
        )
    }
}

// MARK: - TrackedEntry

/// Internal record for a tracked object lifecycle.
private struct TrackedEntry {

    /// Weak reference to the tracked object.
    weak var reference: AnyObject?

    /// Type name for reporting.
    let typeName: String

    /// Expected lifetime behavior.
    let lifetime: ObjectLifetime

    /// When tracking was registered.
    let trackedAt: Date
}
