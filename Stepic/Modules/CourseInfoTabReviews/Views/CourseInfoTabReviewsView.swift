//
//  CourseInfoTabReviewsView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabReviewsView {
    struct Appearance {

    }
}

final class CourseInfoTabReviewsView: UIView {
    let appearance: Appearance

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        return tableView
    }()

    // Proxify delegates
    private weak var pageScrollViewDelegate: UIScrollViewDelegate?

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseInfoTabReviewsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {

    }

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
