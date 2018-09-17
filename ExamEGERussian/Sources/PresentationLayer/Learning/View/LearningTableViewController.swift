//
//  LearningTableViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 30/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class LearningTableViewController: UITableViewController, LearningView {
    var presenter: LearningPresenterProtocol!

    private var viewData = [LearningViewData]()
    private var isFirstTimeWillAppear = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isFirstTimeWillAppear {
            isFirstTimeWillAppear = false
            presenter.refresh()
        }
    }

    // MARK: - LearningView

    func setViewData(_ viewData: [LearningViewData]) {
        self.viewData = viewData
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }

    func displayError(title: String, message: String) {
        presentAlert(withTitle: title, message: message)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - UITableViewDataSource -

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewData.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: LearningTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        configureCell(cell, at: indexPath)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.selectViewData(viewData[indexPath.row])
    }

    private func configureCell(_ cell: LearningTableViewCell, at indexPath: IndexPath) {
        cell.containerTopConstraint.constant = indexPath.row == 0
            ? cell.appearance.sectionInset
            : cell.appearance.minimumItemSpacing
        cell.containerBottomConstraint.constant = indexPath.row == viewData.count - 1
            ? cell.appearance.sectionInset
            : cell.appearance.minimumItemSpacing

        let data = viewData[indexPath.row]
        cell.headerLabel.text = data.title
        cell.descriptionLabel.text = data.description
        cell.timeToCompleteLabel.text = data.timeToComplete
        cell.progressLabel.text = data.progress
    }

    // MARK: - Private API -

    private func setup() {
        tableView.register(cellClass: LearningTableViewCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 170
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
    }

    @objc
    private func refreshContent(_ sender: Any) {
        presenter.refresh()
    }
}
