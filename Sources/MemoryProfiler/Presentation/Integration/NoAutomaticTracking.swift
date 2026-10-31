//
//  NoAutomaticTracking.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Automatic tracking for platforms without lifecycle hooks, such as AppKit.
struct NoAutomaticTracking: AutomaticTrackingInstalling {

    func attach(_ detector: any LeakDetecting, configuration: LeakDetectionConfiguration) {}

    func detach() {}
}
