//
//  ViewControllerUsageProbe.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

/// A removed view controller that is back in a hierarchy (re-pushed, re-presented or re-parented)
/// is in legitimate use, not leaked.
struct ViewControllerUsageProbe: ObjectUsageProbing {

    func isObjectInUse(_ object: AnyObject) -> Bool {
        guard let controller = object as? UIViewController else { return false }
        return MainActor.assumeIsolated {
            controller.parent != nil
                || controller.presentingViewController != nil
                || controller.viewIfLoaded?.window != nil
        }
    }
}
#endif
