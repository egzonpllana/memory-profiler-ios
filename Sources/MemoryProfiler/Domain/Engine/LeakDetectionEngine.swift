//
//  LeakDetectionEngine.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Lifecycle leak detection.
///
/// Each expectation holds the object weakly, observes its deallocation through an associated
/// sentinel, and checks it on the main thread when the grace period ends. Objects still alive
/// are reported once; a later deallocation publishes a late-release resolution.
final class LeakDetectionEngine: LeakDetecting {

    // MARK: - Properties

    private let dependencies: LeakDetectionDependencies
    private let configuration: LockedState<LeakDetectionConfiguration>
    private let store = DeallocationExpectationStore()
    private let budgets: InstanceBudgetTracker

    // MARK: - Initialization

    init(configuration: LeakDetectionConfiguration, dependencies: LeakDetectionDependencies) {
        self.configuration = LockedState(configuration)
        self.dependencies = dependencies
        self.budgets = InstanceBudgetTracker(dependencies: dependencies)
    }

    // MARK: - LeakDetecting

    func configure(_ configuration: LeakDetectionConfiguration) {
        self.configuration.withLock { $0 = configuration }
    }

    func expectDeallocation(of object: AnyObject, request: DeallocationRequest) {
        let configuration = self.configuration.value
        let descriptor = dependencies.inspector.describe(object)
        let address = DisguisedAddress(address: dependencies.inspector.address(of: object))
        guard descriptor.allocationSize > 0,
              !LeakExemptionPolicy.isExempt(object, typeName: descriptor.typeName, filter: configuration.filter),
              !store.isTracking(address) else { return }
        let draft = ExpectationDraft(
            address: address,
            descriptor: descriptor,
            request: request,
            context: makeContext(for: request, capturesCallStack: configuration.diagnostics.capturesCallStack)
        )
        let isObservable = dependencies.deallocationObserver.canObserveDeallocation(of: object)
        let token = store.register(at: address) {
            draft.expectation(token: $0, object: object, isObservable: isObservable)
        }
        guard let token else { return }
        let gracePeriod = request.gracePeriod ?? configuration.gracePeriod
        schedule(token, for: object, observingDeallocation: isObservable, gracePeriod: gracePeriod)
    }

    func trackInstance(_ object: AnyObject, budget: Int, location: SourceLocation) {
        budgets.trackInstance(object, budget: budget, location: location)
    }

    func currentLeaks() -> [LeakReport] {
        store.leakedReports()
    }

    func reset() {
        store.removeAll()
    }

    // MARK: - Private Methods

    private func makeContext(
        for request: DeallocationRequest,
        capturesCallStack: Bool
    ) -> DeallocationExpectationContext {
        DeallocationExpectationContext(
            reason: request.reason,
            location: request.location,
            expectedAt: dependencies.clock.now,
            callStack: capturesCallStack ? dependencies.inspector.callStack() : []
        )
    }

    private func schedule(
        _ token: UInt64,
        for object: AnyObject,
        observingDeallocation: Bool,
        gracePeriod: Duration
    ) {
        if observingDeallocation {
            dependencies.deallocationObserver.observeDeallocation(of: object) { [weak self] in
                self?.handleDeallocation(of: token)
            }
        }
        dependencies.delayedExecutor.executeOnMain(after: gracePeriod) { [weak self] in
            self?.evaluateDeadline(of: token)
        }
    }

    /// Runs on the main thread, so a temporary strong reference taken by a weak load is always
    /// released on the main thread, which UIKit objects require.
    private func evaluateDeadline(of token: UInt64) {
        guard let expectation = store.pendingExpectation(for: token) else { return }
        guard expectation.liveness.mayBeAlive, !expectation.isBackInUse else {
            store.remove(token)
            return
        }
        confirmLeak(expectation)
    }

    private func confirmLeak(_ expectation: DeallocationExpectation) {
        let report = expectation.makeReport(detectedAt: dependencies.clock.now)
        switch configuration.value.diagnostics.retentionAnalysis {
        case .disabled:
            guard store.advance(expectation.token, to: .leaked(report)) else { return }
            dependencies.publisher.publish(.leakDetected(report))
        case .referrerScan(let maxDepth):
            guard store.advance(expectation.token, to: .analyzing(report)) else { return }
            analyzeRetention(of: expectation, maxDepth: maxDepth)
        }
    }

    private func analyzeRetention(of expectation: DeallocationExpectation, maxDepth: Int) {
        let token = expectation.token
        dependencies.referrerScanner.analyzeRetention(
            of: expectation.address,
            rootTypeName: expectation.descriptor.typeName,
            maxDepth: maxDepth,
            ignoredBlocks: store.boxAddresses()
        ) { [weak self] analysis in
            guard let self, let report = self.store.completeAnalysis(token, retention: analysis) else { return }
            self.dependencies.publisher.publish(.leakDetected(report))
        }
    }

    /// Runs on the deallocating thread.
    private func handleDeallocation(of token: UInt64) {
        guard let expectation = store.remove(token), case .leaked(let report) = expectation.phase else { return }
        let resolution = LeakResolution(report: report, releasedAt: dependencies.clock.now)
        dependencies.publisher.publish(.leakResolved(resolution))
    }
}
