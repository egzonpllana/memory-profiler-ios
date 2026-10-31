//
//  EventKind.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import UIKit

/// Visual category of a profiler event.
enum EventKind: String {
    case leak
    case lateRelease
    case budget
    case growth
    case threshold
    case pressure

    var symbolName: String {
        switch self {
        case .leak: return "drop.triangle.fill"
        case .lateRelease: return "clock.arrow.circlepath"
        case .budget: return "person.2.badge.gearshape.fill"
        case .growth: return "chart.line.uptrend.xyaxis"
        case .threshold: return "gauge.with.dots.needle.67percent"
        case .pressure: return "exclamationmark.octagon.fill"
        }
    }

    var tint: UIColor {
        switch self {
        case .leak, .budget: return .systemRed
        case .lateRelease: return .systemGreen
        case .growth, .threshold: return .systemOrange
        case .pressure: return .systemPurple
        }
    }
}
