//
//  DetailViewModel.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// View model that notifies its screen through a stored closure.
@MainActor
final class DetailViewModel {

    var onChange: (() -> Void)?
    private(set) var headline = "Order #4711"

    func load() {
        headline = "Order #4711 (loaded)"
        onChange?()
    }
}
