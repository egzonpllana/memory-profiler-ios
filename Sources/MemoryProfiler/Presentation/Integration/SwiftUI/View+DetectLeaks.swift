//
//  View+DetectLeaks.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#if canImport(SwiftUI)
import SwiftUI

extension View {

    /// Reports `objects` as leaked if they are still alive shortly after this view leaves the hierarchy.
    ///
    /// Apply it in the view that owns the objects, for example the one holding the
    /// `@StateObject` or `@State` view model:
    ///
    /// ```swift
    /// var body: some View {
    ///     content.detectLeaks(of: viewModel)
    /// }
    /// ```
    ///
    /// - Parameter objects: Objects whose lifetime should end with the view. Held weakly.
    /// - Returns: The modified view.
    public func detectLeaks(
        of objects: AnyObject...,
        fileID: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) -> some View {
        modifier(
            LeakDetectionModifier(
                targets: objects.map { WeakObjectBox($0) },
                location: SourceLocation(fileID: fileID, line: line, function: function)
            )
        )
    }
}
#endif
