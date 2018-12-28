//
//  CourseInfoTabSyllabusView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabSyllabusView {
    struct Appearance {
        let headerViewHeight: CGFloat = 60
    }
}

final class CourseInfoTabSyllabusView: UIView {
    let appearance: Appearance

    private lazy var headerView = CourseInfoTabSyllabusHeaderView()

    private weak var pageScrollViewDelegate: UIScrollViewDelegate?
    private weak var tableViewDelegate: (UITableViewDelegate & UITableViewDataSource)?

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        tableView.estimatedSectionHeaderHeight = 90.0
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionFooterHeight = 1.1

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0

        tableView.register(cellClass: CourseInfoTabSyllabusTableViewCell.self)

        // Should use `self` as delegate to proxify some delegate methods
        tableView.delegate = self
        tableView.dataSource = self.tableViewDelegate

        return tableView
    }()

    init(
        frame: CGRect = .zero,
        tableViewDelegate: (UITableViewDelegate & UITableViewDataSource),
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.tableViewDelegate = tableViewDelegate
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTableViewData(delegate: UITableViewDelegate & UITableViewDataSource) {
        self.tableViewDelegate = delegate

        self.tableView.dataSource = self.tableViewDelegate
        self.tableView.reloadData()
    }
}

extension CourseInfoTabSyllabusView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
//        self.addSubview(self.headerView)
        self.addSubview(self.tableView)
    }

    func makeConstraints() {
//        self.headerView.translatesAutoresizingMaskIntoConstraints = false
//        self.headerView.snp.makeConstraints { make in
//            make.top.leading.trailing.equalToSuperview()
//            make.height.equalTo(self.appearance.headerViewHeight)
//        }

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview()
//            make.top.equalTo(self.headerView.snp.bottom)
        }
    }
}

extension CourseInfoTabSyllabusView: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageScrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }

    func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        self.tableViewDelegate?.tableView?(
            tableView,
            willDisplayHeaderView: view,
            forSection: section
        )
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.tableViewDelegate?.tableView?(
            tableView,
            viewForHeaderInSection: section
        )
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tableViewDelegate?.tableView?(
            tableView,
            willDisplay: cell,
            forRowAt: indexPath
        )
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tableViewDelegate?.tableView?(
            tableView,
            didEndDisplaying: cell,
            forRowAt: indexPath
        )
    }

    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        self.tableViewDelegate?.tableView?(
            tableView,
            didEndDisplayingHeaderView: view,
            forSection: section
        )
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension CourseInfoTabSyllabusView: CourseInfoScrollablePageViewProtocol {
    var scrollViewDelegate: UIScrollViewDelegate? {
        get {
            return self.pageScrollViewDelegate
        }
        set {
            self.pageScrollViewDelegate = newValue
        }
    }

    var contentInsets: UIEdgeInsets {
        get {
            return self.tableView.contentInset
        }
        set {
            self.tableView.contentInset = newValue
        }
    }

    var contentOffset: CGPoint {
        get {
            return self.tableView.contentOffset
        }
        set {
            self.tableView.contentOffset = newValue
        }
    }

    @available(iOS 11.0, *)
    var contentInsetAdjustmentBehavior: UIScrollViewContentInsetAdjustmentBehavior {
        get {
            return self.tableView.contentInsetAdjustmentBehavior
        }
        set {
            self.tableView.contentInsetAdjustmentBehavior = newValue
        }
    }
}
