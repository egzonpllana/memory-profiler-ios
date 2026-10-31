//
//  DeinitTracker.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// One-line deallocation checks that report through `MemoryProfilerService.shared`.
///
/// ```swift
/// func close() {
///     DeinitTracker.expectDeinit(of: viewModel)
///     navigationController?.popViewController(animated: true)
/// }
/// ```
public enum DeinitTracker {

    /// Declares that `object` should deallocate within the grace period from now.
    ///
    /// - Parameters:
    ///   - object: The object whose owning scope just ended.
    ///   - gracePeriod: Allowed lifetime from now; `nil` uses the configured grace period.
    public static func expectDeinit(
        of object: AnyObject,
        within gracePeriod: Duration? = nil,
        fileID: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) {
        MemoryProfilerService.shared.expectDeallocation(
            of: object,
            gracePeriod: gracePeriod,
            reason: .manual,
            location: SourceLocation(fileID: fileID, line: line, function: function)
        )
    }
}
