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

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = true
        tableView.separatorStyle = .none

        tableView.estimatedSectionHeaderHeight = 90.0
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionFooterHeight = 1.1

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0

        tableView.register(cellClass: CourseInfoTabSyllabusTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self

        return tableView
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIViewNoIntrinsicMetric,
            height: self.tableView.contentSize.height + self.appearance.headerViewHeight
        )
    }

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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
        self.frame = CGRect(
            x: self.frame.origin.x,
            y: self.frame.origin.y,
            width: self.frame.width,
            height: 200
        )
    }
}

extension CourseInfoTabSyllabusView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.headerView)
        self.addSubview(self.tableView)
    }

    func makeConstraints() {
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.headerViewHeight)
        }

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.headerView.snp.bottom)
        }
    }
}

extension CourseInfoTabSyllabusView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseInfoTabSyllabusTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        print(indexPath)
        cell.updateConstraintsIfNeeded()
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return CourseInfoTabSyllabusSectionView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        print("display \(section)")
    }
}

extension CourseInfoTabSyllabusView: UITableViewDelegate {

}
