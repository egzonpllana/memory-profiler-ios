//
//  MemoryEventBroadcasterTests.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import XCTest
@testable import MemoryProfiler

final class MemoryEventBroadcasterTests: XCTestCase {

    func testStreamsAndHandlersReceiveEvents() async {
        let broadcaster = MemoryEventBroadcaster(observers: [])
        let first = broadcaster.makeStream()
        let second = broadcaster.makeStream()
        broadcaster.publish(.systemMemoryPressure(.warning))

        var firstIterator = first.makeAsyncIterator()
        var secondIterator = second.makeAsyncIterator()
        let firstEvent = await firstIterator.next()
        let secondEvent = await secondIterator.next()

        XCTAssertEqual(firstEvent, .systemMemoryPressure(.warning))
        XCTAssertEqual(secondEvent, .systemMemoryPressure(.warning))
    }

    func testCancelledHandlerStopsReceiving() {
        let broadcaster = MemoryEventBroadcaster(observers: [])
        let received = LockedState(0)
        let subscription = broadcaster.addHandler { _ in received.withLock { $0 += 1 } }
        broadcaster.publish(.systemMemoryPressure(.normal))
        subscription.cancel()
        broadcaster.publish(.systemMemoryPressure(.normal))

        let drained = expectation(description: "queue drained")
        broadcaster.addHandler { _ in drained.fulfill() }
        broadcaster.publish(.systemMemoryPressure(.critical))
        wait(for: [drained], timeout: 2)

        XCTAssertEqual(received.value, 1)
    }
}
