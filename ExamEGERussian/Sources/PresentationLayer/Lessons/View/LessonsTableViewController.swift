//
//  LessonsTableViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD

extension LessonsTableViewController {
    struct Appearance {
        let tableViewEstimatedRowHeight: CGFloat = 60.0
    }
}

final class LessonsTableViewController: UITableViewController {
    var presenter: LessonsPresenterProtocol!

    var state: LessonsViewState = .idle {
        didSet {
            switch state {
            case .idle:
                SVProgressHUD.dismiss()
            case .fetching:
                SVProgressHUD.show()
            }
        }
    }

    private let appearance: Appearance

    private var lessons = [LessonsViewData]() {
        didSet {
            tableView.reloadData()
            lessonsRefreshControl.endRefreshing()
        }
    }

    private var headerView: LessonTableHeaderView? {
        return tableView.tableHeaderView as? LessonTableHeaderView
    }

    private lazy var lessonsRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

        return refreshControl
    }()

    // MARK: - Init

    init(appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        coordinator.animate(alongsideTransition: { _ in
            self.triggerHeaderViewLayoutUpdate()
        })
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

    // MARK: - Private API -

    private func setup() {
        tableView.register(cellClass: LessonTableViewCell.self)

        if #available(iOS 10.0, *) {
            tableView.refreshControl = lessonsRefreshControl
        } else {
            tableView.addSubview(lessonsRefreshControl)
        }

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = appearance.tableViewEstimatedRowHeight

        let headerView: LessonTableHeaderView = .fromNib()
        tableView.tableHeaderView = headerView
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

    func updateHeader(title: String, subtitle: String, colors: [UIColor]) {
        headerView?.titleLabel.text = title
        headerView?.subtitleLabel.text = subtitle
        headerView?.appearance = .init(gradientColors: colors)
        triggerHeaderViewLayoutUpdate()
    }

    func displayError(title: String, message: String) {
        presentAlert(withTitle: title, message: message)
    }
}

// MARK: - LessonsTableViewController (Header View) -

extension LessonsTableViewController {
    private func layoutHeaderView() {
        guard let headerView = headerView else {
            return
        }

        let height = headerView.layoutHeight
        var headerFrame = headerView.frame

        if height != headerFrame.size.height {
            headerFrame.size.height = height
            headerView.frame = headerFrame
            tableView.tableHeaderView = headerView
        }
    }

    private func triggerHeaderViewLayoutUpdate() {
        tableView.tableHeaderView?.setNeedsLayout()
        tableView.tableHeaderView?.layoutIfNeeded()
    }
}
