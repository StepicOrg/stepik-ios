//
//  CourseListVerticalViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import FLKAutoLayout

class CourseListVerticalViewController: CourseListViewController {
    let tableView: UITableView = UITableView()

//    var refreshControl: UIRefreshControl? = UIRefreshControl()

    override func viewDidLoad() {
        delegate = self
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.clear
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
        paginationView.backgroundColor = UIColor.clear
        return paginationView
    }()

    private func getChangedIndexes(changedCourses: [CourseViewData], courses: [CourseViewData]) -> [Int] {
        var changedIndexes: [Int] = []
        for (id, course) in courses.enumerated() {
            if let _ = changedCourses.filter({ $0.id == course.id }).first {
                changedIndexes += [id]
            }
        }
        return changedIndexes
    }
}

extension CourseListVerticalViewController : CourseListViewControllerDelegate {
    func setupContentView() {
        self.view.addSubview(tableView)
        tableView.align(toView: self.view)
        tableView.register(UINib(nibName: "CourseWidgetTableViewCell", bundle: nil), forCellReuseIdentifier: "CourseWidgetTableViewCell")

        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        #if swift(>=3.2)
            if #available(iOS 11.0, *) {
                tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
            }
        #endif
    }

    func setupRefresh() {
//        refreshControl?.addTarget(self, action: #selector(CourseListViewController.refresh), for: .valueChanged)
//        if #available(iOS 10.0, *) {
//            tableView.refreshControl = refreshControl
//        } else {
//            tableView.addSubview(refreshControl ?? UIView())
//        }
//        refreshControl?.layoutIfNeeded()
    }

    func reloadData() {
        tableView.reloadData()
    }

    func updatePagination() {
        switch paginationStatus {
        case .none:
            tableView.tableFooterView = nil
        case .loading:
            if tableView.tableFooterView != paginationView {
                tableView.tableFooterView = paginationView
            }
            switch (colorMode ?? .light) {
            case .light:
                paginationView.activityIndicator.color = UIColor.mainDark
            case .dark:
                paginationView.activityIndicator.color = UIColor.white
            }
            paginationView.setLoading()
        case .error:
            if tableView.tableFooterView != paginationView {
                tableView.tableFooterView = paginationView
            }
            paginationView.setError()
        }
    }

    func setUserInteraction(enabled: Bool) {
        tableView.isUserInteractionEnabled = enabled
    }

    func indexesForVisibleCells() -> [Int] {
        return tableView.indexPathsForVisibleRows?.map { $0.row } ?? []
    }

    func indexPathForIndex(index: Int) -> IndexPath {
        return IndexPath(row: index, section: 0)
    }

    func addElements(atIndexPaths indexPaths: [IndexPath]) {
        let offsetBefore = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .none)
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(offsetBefore, animated: false)
    }

    func widgetForCell(atIndex index: Int) -> CourseWidgetView? {
        return (tableView.cellForRow(at: indexPathForIndex(index: index)) as? CourseWidgetTableViewCell)?.widgetView
    }

    func getSourceCellFor3dTouch(location: CGPoint) -> (view: UIView, index: Int)? {
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

        return (view: cell, index: indexPath.row)
    }

    func updateCells(deletingIndexPaths: [IndexPath], insertingIndexPaths: [IndexPath]) {
        tableView.beginUpdates()
        tableView.insertRows(at: insertingIndexPaths, with: .automatic)
        tableView.deleteRows(at: deletingIndexPaths, with: .automatic)
        tableView.endUpdates()
    }
}

extension CourseListVerticalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectCourse(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CourseListVerticalViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowLoadingWidgets {
            return Int(tableView.frame.height) / 100
        } else {
            return courses.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < courses.count || shouldShowLoadingWidgets else {
            return UITableViewCell()
        }

        if indexPath.row == courses.count - 1 && paginationStatus == .loading {
            presenter?.loadNextPage()
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CourseWidgetTableViewCell", for: indexPath) as? CourseWidgetTableViewCell else {
            return UITableViewCell()
        }

        cell.selectionStyle = .none
        if shouldShowLoadingWidgets {
            cell.isLoading = true
        } else {
            cell.setup(courseViewData: courses[indexPath.row], colorMode: colorMode)
        }
        return cell
    }
}
