//
//  InstanceBudgetOutcome.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// Result of counting an instance toward its type budget.
enum InstanceBudgetOutcome: Equatable {

    /// The instance was already counted.
    case duplicate

    /// Counted; the type is within its budget or was already reported as exceeding it.
    case withinBudget

    /// Counted; the type just exceeded its budget.
    case exceeded(liveCount: Int)
}
