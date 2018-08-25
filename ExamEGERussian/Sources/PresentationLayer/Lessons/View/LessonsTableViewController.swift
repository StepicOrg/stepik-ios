//
//  LessonsTableViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class LessonsTableViewController: UITableViewController {
    var presenter: LessonsPresenter!

    private var lessons = [LessonsViewData]() {
        didSet {
            tableView.reloadData()
            lessonsRefreshControl.endRefreshing()
            updateHeaderViewContent()
        }
    }

    private lazy var lessonsRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

        return refreshControl
    }()

    private var headerView: LessonHeaderTableView? {
        return tableView.tableHeaderView as? LessonHeaderTableView
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter.refresh()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutHeaderView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        triggerHeaderViewLayoutUpdate()
        tableView.setContentOffset(.zero, animated: false)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lesson = lessons[indexPath.row]

        let cell: LessonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.numberLabel.text = "\(indexPath.row + 1)."
        cell.titleLabel.text = lesson.title
        cell.subtitleLabel.text = lesson.subtitle

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.selectLesson(with: lessons[indexPath.row])
    }

    // MARK: - Private API

    private func setup() {
        tableView.registerNib(for: LessonTableViewCell.self)

        if #available(iOS 10.0, *) {
            tableView.refreshControl = lessonsRefreshControl
        } else {
            tableView.addSubview(lessonsRefreshControl)
        }

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60

        tableView.tableHeaderView = LessonHeaderTableView.fromNib() as LessonHeaderTableView
        updateHeaderViewContent()
    }

    @objc
    private func refreshData(_ sender: Any) {
        presenter.refresh()
    }
}

// MARK: - LessonsTableViewController: LessonsView -

extension LessonsTableViewController: LessonsView {
    func setLessons(_ lessons: [LessonsViewData]) {
        self.lessons = lessons
    }

    func displayError(title: String, message: String) {
        presentAlert(withTitle: title, message: message)
    }
}

// MARK: - LessonsTableViewController (Header View) -

extension LessonsTableViewController {
    private func layoutHeaderView() {
        if let headerView = headerView {
            let height = headerView.layoutHeight
            var headerFrame = headerView.frame

            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }

    private func triggerHeaderViewLayoutUpdate() {
        tableView.tableHeaderView?.setNeedsLayout()
        tableView.tableHeaderView?.layoutIfNeeded()
    }

    private func updateHeaderViewContent() {
        headerView?.titleLabel.text = lessons.first?.headerTitle
        headerView?.subtitleLabel.text = lessons.first?.headerSubtitle
        triggerHeaderViewLayoutUpdate()
    }
}
