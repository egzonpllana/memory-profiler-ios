//
//  AutomaticTrackingInstalling.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Installs platform hooks that create deallocation expectations without app code.
protocol AutomaticTrackingInstalling: Sendable {

    /// Routes platform lifecycle callbacks to `detector` using `configuration`.
    func attach(_ detector: any LeakDetecting, configuration: LeakDetectionConfiguration)

    /// Stops routing callbacks.
    func detach()
}
