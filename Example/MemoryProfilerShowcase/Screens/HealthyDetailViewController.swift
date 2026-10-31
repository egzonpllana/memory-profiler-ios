//
//  HealthyDetailViewController.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import UIKit

/// Same screen as `LeakyDetailViewController`, with a weak capture.
final class HealthyDetailViewController: DetailViewController {

    init() {
        super.init(explanation: """
        This screen is healthy.

        viewModel.onChange = { [weak self] in ... } does not retain the screen. Go back: no event is reported.
        """)
    }

    override func bindViewModel() {
        viewModel.onChange = { [weak self] in
            self?.title = self?.viewModel.headline
        }
    }
}
