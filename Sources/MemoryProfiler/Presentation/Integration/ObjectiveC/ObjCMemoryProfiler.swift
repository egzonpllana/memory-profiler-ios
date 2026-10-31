//
//  ObjCMemoryProfiler.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Objective-C entry points to `MemoryProfilerService.shared`.
///
/// ```objc
/// [MPMemoryProfiler start];
/// [MPMemoryProfiler expectDeallocationOf:self.viewModel];
/// [MPMemoryProfiler setLeakHandler:^(MPLeakReport *report) { NSLog(@"%@", report.summary); }];
/// ```
@objc(MPMemoryProfiler)
public final class ObjCMemoryProfiler: NSObject {

    // MARK: - Properties

    private static let objectiveCLocation = SourceLocation(fileID: "Objective-C", line: 0, function: "")
    private static let maximumGraceSeconds: TimeInterval = 31_536_000
    private static let leakSubscription = LockedState<EventSubscription?>(nil)

    private static var profiler: MemoryProfilerService {
        MemoryProfilerService.shared
    }

    // MARK: - Initialization

    private override init() {
        super.init()
    }

    // MARK: - Lifecycle

    /// Starts monitoring and automatic view controller tracking.
    @objc public static func start() {
        profiler.start()
    }

    /// Stops monitoring.
    @objc public static func stop() {
        profiler.stop()
    }

    // MARK: - Leak Detection

    /// Declares that `object` should deallocate within the configured grace period.
    @objc(expectDeallocationOf:)
    public static func expectDeallocation(of object: AnyObject) {
        profiler.expectDeallocation(of: object, gracePeriod: nil, reason: .manual, location: objectiveCLocation)
    }

    /// Declares that `object` should deallocate within `seconds`. NaN or infinite values use the
    /// configured grace period; other values are clamped to 0...one year.
    @objc(expectDeallocationOf:within:)
    public static func expectDeallocation(of object: AnyObject, within seconds: TimeInterval) {
        profiler.expectDeallocation(
            of: object,
            gracePeriod: gracePeriod(seconds: seconds),
            reason: .manual,
            location: objectiveCLocation
        )
    }

    /// Counts `object` toward its class's live instance budget. Call it from `init`.
    @objc(trackInstance:budget:)
    public static func trackInstance(_ object: AnyObject, budget: Int) {
        profiler.trackInstance(object, budget: budget, location: objectiveCLocation)
    }

    /// Logs the current footprint with a context label.
    @objc(logMemoryUsageWithContext:)
    public static func logMemoryUsage(context: String) {
        profiler.logMemoryUsage(context: context)
    }

    private static func gracePeriod(seconds: TimeInterval) -> Duration? {
        guard seconds.isFinite else { return nil }
        return .milliseconds(Int64(min(max(seconds, 0), maximumGraceSeconds) * 1000))
    }

    /// Calls `handler` on a background queue for every detected leak. Pass `nil` to remove it.
    @objc(setLeakHandler:)
    public static func setLeakHandler(_ handler: (@Sendable (ObjCLeakReport) -> Void)?) {
        let subscription = handler.map { handler in
            profiler.addEventHandler { event in
                guard case .leakDetected(let report) = event else { return }
                handler(ObjCLeakReport(report: report))
            }
        }
        let previous = leakSubscription.withLock { stored -> EventSubscription? in
            let replaced = stored
            stored = subscription
            return replaced
        }
        previous?.cancel()
    }
}
