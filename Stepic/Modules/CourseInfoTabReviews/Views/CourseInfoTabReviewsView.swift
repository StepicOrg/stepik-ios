//
//  CourseInfoTabReviewsView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class CourseInfoTabReviewsView: UIView {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.separatorStyle = .none
        tableView.allowsSelection = false

        tableView.delegate = self
        tableView.register(cellClass: CourseInfoTabReviewsTableViewCell.self)

        let footerView = PaginationView(frame: .zero)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        tableView.tableFooterView = footerView

        return tableView
    }()

    // Proxify delegates
    private weak var pageScrollViewDelegate: UIScrollViewDelegate?

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTableViewData(dataSource: UITableViewDataSource) {
        self.tableView.dataSource = dataSource
        self.tableView.reloadData()
    }
}

extension CourseInfoTabReviewsView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.tableView)
    }

    func makeConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension CourseInfoTabReviewsView: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageScrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }
}

extension CourseInfoTabReviewsView: CourseInfoScrollablePageViewProtocol {
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
