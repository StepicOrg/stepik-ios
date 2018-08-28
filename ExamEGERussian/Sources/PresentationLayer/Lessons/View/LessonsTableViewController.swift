//
//  LessonsTableViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension LessonsTableViewController {
    struct Appearance {
        let headerGradientColors = [UIColor(hex: 0x516395), UIColor(hex: 0x4CA0AE)]
        let headerGradientLocations = [0.0, 1.0]
        let headerGradientRotationAngle: CGFloat = 90.0
        let tableViewEstimatedRowHeight: CGFloat = 60.0
    }
}

final class LessonsTableViewController: UITableViewController {
    var presenter: LessonsPresenterProtocol!
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
    private lazy var headerViewGradient: CAGradientLayer = {
        CAGradientLayer(
            colors: appearance.headerGradientColors,
            locations: appearance.headerGradientLocations,
            rotationAngle: appearance.headerGradientRotationAngle
        )
    }()

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

    // MARK: - Private API -

    private func setup() {
        tableView.registerNib(for: LessonTableViewCell.self)

        if #available(iOS 10.0, *) {
            tableView.refreshControl = lessonsRefreshControl
        } else {
            tableView.addSubview(lessonsRefreshControl)
        }

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = appearance.tableViewEstimatedRowHeight

        tableView.tableHeaderView = LessonTableHeaderView.fromNib() as LessonTableHeaderView
        tableView.tableHeaderView?.layer.insertSublayer(headerViewGradient, at: 0)
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

    func updateHeader(title: String, subtitle: String) {
        headerView?.titleLabel.text = title
        headerView?.subtitleLabel.text = subtitle
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
            headerViewGradient.frame = headerView.bounds
        }
    }

    private func triggerHeaderViewLayoutUpdate() {
        tableView.tableHeaderView?.setNeedsLayout()
        tableView.tableHeaderView?.layoutIfNeeded()
    }
}
