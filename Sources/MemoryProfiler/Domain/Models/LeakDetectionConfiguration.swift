//
//  LeakDetectionConfiguration.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Settings for lifecycle-based leak detection.
public struct LeakDetectionConfiguration: Sendable, Equatable {

    // MARK: - Properties

    /// Time an object may stay alive after it is expected to deallocate before it is reported.
    public var gracePeriod: Duration

    /// Objects tracked automatically while monitoring runs.
    public var automaticTracking: Set<AutomaticTrackingTarget>

    /// Action taken in addition to logging when a leak is detected.
    public var alertPolicy: LeakAlertPolicy

    /// Objects excluded from detection.
    public var filter: LeakDetectionFilter

    /// Extra context collected for each report.
    public var diagnostics: LeakDiagnosticsConfiguration

    // MARK: - Initialization

    /// Creates a leak detection configuration.
    ///
    /// - Parameters:
    ///   - gracePeriod: Allowed lifetime after the expectation. Defaults to 2 seconds.
    ///   - automaticTracking: Automatically tracked objects. Defaults to view controllers and their views.
    ///   - alertPolicy: Extra action on detection. Defaults to `.log`.
    ///   - filter: Exclusion rules.
    ///   - diagnostics: Extra report context.
    public init(
        gracePeriod: Duration = .seconds(2),
        automaticTracking: Set<AutomaticTrackingTarget> = [.viewControllers, .views],
        alertPolicy: LeakAlertPolicy = .log,
        filter: LeakDetectionFilter = LeakDetectionFilter(),
        diagnostics: LeakDiagnosticsConfiguration = LeakDiagnosticsConfiguration()
    ) {
        self.gracePeriod = gracePeriod
        self.automaticTracking = automaticTracking
        self.alertPolicy = alertPolicy
        self.filter = filter
        self.diagnostics = diagnostics
    }
}
