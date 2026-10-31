//
//  RuntimeTypeOriginClassifier.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation
import ObjectiveC

/// Classifies classes by the image that defines them, or by module name for runtime-created
/// classes such as generic instantiations. The profiler's own classes count as system classes
/// so they never appear in application scoped results.
struct RuntimeTypeOriginClassifier: TypeOriginClassifying {

    // MARK: - Properties

    private static let profilerModulePrefix = "MemoryProfiler."

    private static let systemPathMarkers = ["/System/Library/", "/usr/lib/", "/Developer/Library/"]

    private static let systemModules: Set<String> = [
        "Swift", "_Concurrency", "_StringProcessing", "Foundation", "CoreFoundation", "ObjectiveC",
        "Dispatch", "Combine", "Observation", "SwiftUI", "UIKit", "AppKit"
    ]

    // MARK: - TypeOriginClassifying

    func isSystemClass(_ type: AnyClass) -> Bool {
        let typeName = String(reflecting: type)
        guard !typeName.hasPrefix(Self.profilerModulePrefix) else { return true }
        guard let imageName = class_getImageName(type) else {
            return isSystemModule(typeName)
        }
        let path = String(cString: imageName)
        return Self.systemPathMarkers.contains { path.contains($0) }
    }

    // MARK: - Private Methods

    /// Runtime-created classes without a Swift module prefix are Objective-C classes made by
    /// frameworks at runtime, such as KVO subclasses and XPC proxies.
    private func isSystemModule(_ typeName: String) -> Bool {
        let components = typeName.split(separator: ".", maxSplits: 1)
        guard components.count == 2, let module = components.first else { return true }
        return Self.systemModules.contains(String(module))
    }
}
