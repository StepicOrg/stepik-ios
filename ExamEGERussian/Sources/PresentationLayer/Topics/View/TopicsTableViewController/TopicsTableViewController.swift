//
//  TopicsTableViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TopicsTableViewController: UITableViewController {

    // MARK: Instance Properties

    var presenter: TopicsPresenter!

    private var topics = [TopicsViewData]() {
        didSet {
            tableView.reloadData()
            topicsRefreshControl.endRefreshing()
        }
    }

    private lazy var topicsRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

        return refreshControl
    }()

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        presenter.refresh()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TopicTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.descriptionTitleLabel.text = topics[indexPath.row].title

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.selectTopic(with: topics[indexPath.row])
    }

    // MARK: - Private API

    private func setupView() {
        tableView.registerNib(for: TopicTableViewCell.self)

        if #available(iOS 10.0, *) {
            tableView.refreshControl = topicsRefreshControl
        } else {
            tableView.addSubview(topicsRefreshControl)
        }
    }
}

// MARK: - TopicsTableViewController (Actions) -

extension TopicsTableViewController {
    @objc
    private func refreshData(_ sender: Any) {
        presenter.refresh()
    }

    @objc
    private func onLogoutClick(_ sender: Any) {
        presenter.logout()
    }

    @objc
    private func onSignInClick(_ sender: Any) {
        presenter.signIn()
    }
}

// MARK: - TopicsTableViewController: TopicsView -

extension TopicsTableViewController: TopicsView {
    func setTopics(_ topics: [TopicsViewData]) {
        self.topics = topics
    }

    func displayError(title: String, message: String) {
        presentAlert(withTitle: title, message: message)
    }
}
