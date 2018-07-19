//
//  TopicsTableViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TopicsTableViewController: UITableViewController {
    var presenter: TopicsPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(for: TopicTableViewCell.self)
        presenter.viewDidLoad()
        title = presenter.titleForScene()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfTopics
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TopicTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        presenter.configure(cell: cell, forRow: indexPath.row)

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelect(row: indexPath.row)
    }
}

// MARK: - TopicsTableViewController: TopicsView -

extension TopicsTableViewController: TopicsView {
    func refreshTopicsView() {
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }

    func displayError(title: String, message: String) {
        presentAlert(withTitle: title, message: message)
    }
}
