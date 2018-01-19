//
//  CourseContentMenuViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 02.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CourseContentMenuViewController: MenuTableViewController {

    var presenter: CourseContentPresenter?

    var sections: [SectionViewData] = []
    var courseInfo: CourseViewData?

    override var segueIdentifier: String { return "ShowDetailSegue" }
    override var cellIdentifier: String { return MenuSectionTableViewCell.reuseIdentifier }

    var additionalCellIdentifier: String { return MenuHeaderCourseTableViewCell.reuseIdentifier }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return sections.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return MenuHeaderCourseTableViewCell.size
        default:
            return MenuSectionTableViewCell.size
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: additionalCellIdentifier, for: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MenuHeaderCourseTableViewCell, let courseInfo = courseInfo {
            cell.setup(with: courseInfo)
        }

        if let cell = cell as? MenuSectionTableViewCell {
            cell.setup(with: indexPath.row + 1, sections[indexPath.row].title)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = performingSegueSourceCellIndexPath else { fatalError("'prepare(for segue:)' called when no performing segues") }

        guard let vc = segue.destination as? SectionTableViewController, segue.identifier == segueIdentifier else { return }

        vc.paragraphIndex = indexPath.row + 1
        vc.section = sections[indexPath.row]

        presenter?.loadUnitsForSection(vc, index: indexPath.row)
    }
}

extension CourseContentMenuViewController: MenuCourseContentView {
    func provide(courseInfo: CourseViewData) {
        self.courseInfo = courseInfo
        tableView.reloadData()
    }

    func provide(sections: [SectionViewData]) {
        self.sections = sections
        tableView.reloadData()
    }
}
