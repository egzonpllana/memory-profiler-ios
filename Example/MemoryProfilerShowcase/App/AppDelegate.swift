//
//  AppDelegate.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import MemoryProfiler
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let profiler = MemoryProfilerService.shared
        profiler.configure(ShowcaseConfiguration.make(baselineFootprint: profiler.currentStats()?.footprint))
        profiler.start()
        EventFeed.shared.startListening(to: profiler)
        return true
    }
}
