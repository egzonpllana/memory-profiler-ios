//
//  ScenarioListViewController.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import UIKit

/// The list of showcase scenarios.
final class ScenarioListViewController: UITableViewController {

    // MARK: - Properties

    private let performer: ScenarioPerformer
    private let sections = ScenarioCatalog.sections
    private let cellIdentifier = "ScenarioCell"

    // MARK: - Initialization

    init(performer: ScenarioPerformer) {
        self.performer = performer
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Memory Profiler"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].scenarios.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].footer
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let scenario = sections[indexPath.section].scenarios[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = scenario.title
        content.secondaryText = scenario.explanation
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let scenario = sections[indexPath.section].scenarios[indexPath.row]
        guard let outcome = performer.perform(scenario.action) else { return }
        let alert = UIAlertController(title: outcome.title, message: outcome.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
