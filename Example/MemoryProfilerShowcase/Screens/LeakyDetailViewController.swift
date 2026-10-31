//
//  LeakyDetailViewController.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import UIKit

/// The closure stored in the view model captures `self` strongly:
/// screen -> viewModel -> onChange -> screen.
final class LeakyDetailViewController: DetailViewController {

    init() {
        super.init(explanation: """
        This screen leaks.

        viewModel.onChange = { self.title = ... } captures the screen strongly, and the screen owns the \
        view model. Go back: about 2 seconds later the Events tab shows the leak and the retain cycle.
        """)
    }

    override func bindViewModel() {
        viewModel.onChange = { self.title = self.viewModel.headline }
    }
}
