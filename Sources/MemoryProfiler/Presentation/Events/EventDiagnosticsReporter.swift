//
//  EventDiagnosticsReporter.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Logs every event and applies the leak alert policy.
final class EventDiagnosticsReporter: MemoryEventObserving {

    // MARK: - Properties

    private let logger: any MemoryLogging
    private let alertHandler: LeakAlertHandler
    private let policy = LockedState(LeakAlertPolicy.log)

    // MARK: - Initialization

    init(logger: any MemoryLogging, alertHandler: LeakAlertHandler) {
        self.logger = logger
        self.alertHandler = alertHandler
    }

    // MARK: - Public Methods

    /// Uses `policy` for later events.
    func updatePolicy(_ policy: LeakAlertPolicy) {
        self.policy.withLock { $0 = policy }
    }

    // MARK: - MemoryEventObserving

    func observe(_ event: MemoryProfilerEvent) {
        let records = MemoryEventLogFormatter.records(for: event)
        for record in records {
            logger.log(record.message, level: record.level, category: record.category)
        }
        alertHandler.handle(event, message: records.first?.message ?? "", policy: policy.value)
    }
}
