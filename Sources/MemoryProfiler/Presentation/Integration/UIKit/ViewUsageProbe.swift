//
//  ViewUsageProbe.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

/// A view that is back in a hierarchy is in use. A view still owned by a living view
/// controller is covered by that controller's own expectation, so it is not reported twice.
struct ViewUsageProbe: ObjectUsageProbing {

    func isObjectInUse(_ object: AnyObject) -> Bool {
        guard let view = object as? UIView else { return false }
        return MainActor.assumeIsolated {
            view.superview != nil || view.window != nil || view.next is UIViewController
        }
    }
}
#endif
