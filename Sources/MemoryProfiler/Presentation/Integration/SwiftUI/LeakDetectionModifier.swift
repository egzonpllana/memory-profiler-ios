//
//  LeakDetectionModifier.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#if canImport(SwiftUI)
import SwiftUI

/// Expects its targets to deallocate when the modified view leaves the hierarchy.
struct LeakDetectionModifier: ViewModifier {

    // MARK: - Properties

    let targets: [WeakObjectBox]
    let location: SourceLocation

    @Environment(\.memoryProfiler) private var profiler
    @State private var sentinel = LeakScopeSentinel()

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        content.onAppear {
            sentinel.arm(targets: targets, profiler: profiler, location: location)
        }
    }
}
#endif
