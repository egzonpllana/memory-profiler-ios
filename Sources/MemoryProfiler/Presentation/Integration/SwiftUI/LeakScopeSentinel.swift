//
//  LeakScopeSentinel.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Lives in a view's state; its deinit marks the end of the view's lifetime.
///
/// SwiftUI may create and discard several instances while re-initializing the view. Only the
/// instance armed by `onAppear` has targets, so the discarded ones deinitialize silently.
final class LeakScopeSentinel: Sendable {

    // MARK: - Types

    private struct Scope {
        var targets: [WeakObjectBox] = []
        var profiler: (any MemoryProfilerServicing)?
        var location = SourceLocation(fileID: "", line: 0, function: "")
    }

    // MARK: - Properties

    private let scope = LockedState(Scope())

    // MARK: - Initialization

    deinit {
        let current = scope.value
        guard let profiler = current.profiler else { return }
        Self.expectDeallocation(of: current.targets, profiler: profiler, location: current.location)
    }

    // MARK: - Public Methods

    /// Records the targets to check when the view goes away. Targets dropped by a re-arm,
    /// such as a replaced view model, are expected to deallocate right away.
    func arm(targets: [WeakObjectBox], profiler: any MemoryProfilerServicing, location: SourceLocation) {
        let previous = scope.withLock { scope -> [WeakObjectBox] in
            let replaced = scope.targets
            scope = Scope(targets: targets, profiler: profiler, location: location)
            return replaced
        }
        let dropped = previous.filter { box in
            guard let object = box.object else { return false }
            return !targets.contains { $0.object === object }
        }
        Self.expectDeallocation(of: dropped, profiler: profiler, location: location)
    }

    // MARK: - Private Methods

    private static func expectDeallocation(
        of boxes: [WeakObjectBox],
        profiler: any MemoryProfilerServicing,
        location: SourceLocation
    ) {
        for box in boxes {
            guard let object = box.object else { continue }
            profiler.expectDeallocation(of: object, gracePeriod: nil, reason: .swiftUIViewRemoved, location: location)
        }
    }
}
