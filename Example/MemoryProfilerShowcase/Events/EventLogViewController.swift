//
//  EventLogViewController.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import MemoryProfiler
import UIKit

/// Live list of every event the profiler published, newest first.
final class EventLogViewController: UITableViewController {

    // MARK: - Properties

    private let feed: EventFeed
    private let cellIdentifier = "EventCell"

    // MARK: - Initialization

    init(feed: EventFeed) {
        self.feed = feed
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Events"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            primaryAction: UIAction { [weak self] _ in self?.feed.clear() }
        )
        feed.addObserver { [weak self] in self?.refresh() }
        refresh()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feed.rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let leaked = MemoryProfilerService.shared.currentLeaks().count
        return "\(feed.rows.count) events, \(leaked) objects currently leaked"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let row = feed.rows[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = row.title
        content.secondaryText = row.detail
        content.secondaryTextProperties.numberOfLines = 0
        content.secondaryTextProperties.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        content.image = UIImage(systemName: row.kind.symbolName)
        content.imageProperties.tintColor = row.kind.tint
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }

    // MARK: - Private Methods

    private func refresh() {
        tableView.reloadData()
        navigationController?.tabBarItem.badgeValue = feed.rows.isEmpty ? nil : "\(feed.rows.count)"
    }
}
