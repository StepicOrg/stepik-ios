//
//  CourseListVerticalViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import FLKAutoLayout

class CourseListVerticalViewController: UIViewController, CourseListView {
    let tableView: UITableView = UITableView()

    var presenter: CourseListPresenter?
    var listType: CourseListType! = CourseListType.enrolled(cachedIds: [])
    var refreshEnabled: Bool! = true
    var refreshControl: UIRefreshControl? = UIRefreshControl()

    var courses: [CourseViewData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = CourseListPresenter(view: self, listType: listType, coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI())
        setupTableView()
        setup3dTouch()
        if refreshEnabled {
            setupRefresh()
        }
        refresh()
    }

    //Setup

    private func setupTableView() {
        self.view.addSubview(tableView)
        tableView.align(toView: self.view)
        tableView.register(UINib(nibName: "CourseWidgetTableViewCell", bundle: nil), forCellReuseIdentifier: "CourseWidgetTableViewCell")

        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        #if swift(>=3.2)
            if #available(iOS 11.0, *) {
                tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
            }
        #endif
    }

    private func setupRefresh() {
        refreshControl?.addTarget(self, action: #selector(CourseListVerticalViewController.refresh), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl ?? UIView())
        }
        refreshControl?.layoutIfNeeded()

    }

    private func setup3dTouch() {
        if(traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: view)
        }
    }

    lazy var paginationView: LoadingPaginationView = {
        let paginationView = LoadingPaginationView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
        paginationView.refreshAction = {
            [weak self] in
            guard let presenter = self?.presenter else {
                return
            }
            presenter.loadNextPage()
        }

        return paginationView
    }()

    func refresh() {
        presenter?.refresh()
    }

    func display(courses: [CourseViewData]) {
        self.courses = courses
        tableView.reloadData()
    }

    private func getChangedIndexes(changedCourses: [CourseViewData], courses: [CourseViewData]) -> [Int] {
        var changedIndexes: [Int] = []
        for (id, course) in courses.enumerated() {
            if let _ = changedCourses.filter({ $0.id == course.id }).first {
                changedIndexes += [id]
            }
        }
        return changedIndexes
    }

    func update(updatedCourses: [CourseViewData], courses: [CourseViewData]) {
        self.courses = courses
        let updatingIndexes: [Int] = getChangedIndexes(changedCourses: updatedCourses, courses: courses)

        let visibleIndexPaths = Set<IndexPath>(tableView.indexPathsForVisibleRows ?? [])
        let updatingIndexPaths = Set<IndexPath>(updatingIndexes.map({ IndexPath(row: $0, section: 0) }))
        let visibleUpdating = Array(updatingIndexPaths.intersection(visibleIndexPaths))
        for indexPath in visibleUpdating {
            if let cell = tableView.cellForRow(at: indexPath) as? CourseWidgetTableViewCell {
                cell.widgetView.progress = courses[indexPath.row].progress
                cell.widgetView.rating = courses[indexPath.row].rating
            }
        }
    }

    func add(addedCourses: [CourseViewData], courses: [CourseViewData]) {
        self.courses = courses
        let addedIndexes: [Int] = getChangedIndexes(changedCourses: addedCourses, courses: courses)
        let addedIndexPaths = addedIndexes.map({ IndexPath(row: $0, section: 0) })

        tableView.insertRows(at: addedIndexPaths, with: .automatic)
    }

    func setRefreshing(isRefreshing: Bool) {
        if isRefreshing {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }

    func setLoadingNextPage(isLoading: Bool) {
        if isLoading {
            paginationView.setLoading()
        } else {
            paginationView.setError()
        }
    }

    func setNextPageEnabled(isEnabled: Bool) {
        if isEnabled {
            tableView.tableFooterView = paginationView
            paginationView.setLoading()
        } else {
            tableView.tableFooterView = nil
        }
    }

    func present(controller: UIViewController) {
        self.present(controller, animated: true, completion: nil)
    }

}

extension CourseListVerticalViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        let locationInTableView = tableView.convert(location, from: self.view)

        guard let indexPath = tableView.indexPathForRow(at: locationInTableView) else {
            return nil
        }

        guard indexPath.row < courses.count else {
            return nil
        }

        guard let cell = tableView.cellForRow(at: indexPath) as? CourseWidgetTableViewCell else {
            return nil
        }

        previewingContext.sourceRect = cell.frame

        return presenter?.getViewControllerFor3DTouchPreviewing(forCourseAtIndex: indexPath.row, withSourceView: cell)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
        AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Course.popped)
    }
}

extension CourseListVerticalViewController: UITableViewDelegate {

}

extension CourseListVerticalViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard indexPath.row < courses.count else {
            return UITableViewCell()
        }

        if indexPath.row == courses.count - 1 && presenter?.hasNextPage == true {
            presenter?.loadNextPage()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseWidgetTableViewCell", for: indexPath) as! CourseWidgetTableViewCell

        cell.setup(courseViewData: courses[indexPath.row])
        return cell
    }
}
