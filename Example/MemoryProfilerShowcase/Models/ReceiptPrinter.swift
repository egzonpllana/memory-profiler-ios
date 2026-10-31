//
//  ReceiptPrinter.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Keeps itself alive for a few seconds through a pending closure, then goes away on its own.
final class ReceiptPrinter: Sendable {

    static let printingDelay: TimeInterval = 4

    func printAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.printingDelay) {
            self.finishPrinting()
        }
    }

    private func finishPrinting() {}
}
