//
//  DetailViewController.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import UIKit

/// Shared layout for the leaky and healthy detail screens.
class DetailViewController: UIViewController {

    // MARK: - Properties

    let viewModel = DetailViewModel()
    private let explanation: String

    // MARK: - Initialization

    init(explanation: String) {
        self.explanation = explanation
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = explanation
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        bindViewModel()
        viewModel.load()
    }

    /// Connects the view model's change callback to the screen.
    func bindViewModel() {}
}
