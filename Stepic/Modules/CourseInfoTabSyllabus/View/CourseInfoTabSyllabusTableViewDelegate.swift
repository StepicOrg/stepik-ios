//
//  CourseInfoTabSyllabusTableViewDelegate.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class CourseInfoTabSyllabusTableViewDelegate: NSObject,
                                                    UITableViewDelegate,
                                                    UITableViewDataSource {
    weak var delegate: CourseInfoTabSyllabusViewControllerDelegate?
    var viewModels: [CourseInfoTabSyllabusSectionViewModel]

    init(viewModels: [CourseInfoTabSyllabusSectionViewModel] = []) {
        self.viewModels = viewModels
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModels[section].units.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseInfoTabSyllabusTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        if let viewModel = self.viewModels[safe: indexPath.section]?.units[safe: indexPath.row] {
            cell.configure(viewModel: viewModel)
        }

        cell.updateConstraintsIfNeeded()
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = CourseInfoTabSyllabusSectionView()

        if let viewModel = self.viewModels[safe: section] {
            sectionView.configure(viewModel: viewModel)
        }
        return sectionView
    }

    func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        let titles = self.viewModels[section].units.map { $0.title }
        if !titles.contains(where: { $0 == "LOADING" }) {
            return
        }

        self.delegate?.sectionWillDisplay(self.viewModels[section])
    }
}
