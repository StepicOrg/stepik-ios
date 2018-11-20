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
        let tableViewHeaderHeight: CGFloat = 60
    }
}

final class CourseInfoTabSyllabusView: UIView {
    let appearance: Appearance

    private lazy var tableViewHeader = CourseInfoTabSyllabusHeaderView()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = self.tableViewHeader
        return tableView
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIViewNoIntrinsicMetric,
            height: self.tableView.contentSize.height
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
        self.tableView.layoutTableHeaderView()
    }
}

extension CourseInfoTabSyllabusView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.tableView)
    }

    func makeConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.tableViewHeader.translatesAutoresizingMaskIntoConstraints = false
        self.tableViewHeader.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.tableViewHeaderHeight)
        }
    }
}

extension CourseInfoTabSyllabusView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}

extension CourseInfoTabSyllabusView: UITableViewDelegate {

}
