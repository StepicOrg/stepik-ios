//
//  LearningTableViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 30/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class LearningTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(for: LearningTableViewCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 170
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: LearningTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.containerTopConstraint.constant = indexPath.row == 0
            ? cell.appearance.sectionInset
            : cell.appearance.minimumItemSpacing
        cell.containerBottomConstraint.constant = indexPath.row == 4
            ? cell.appearance.sectionInset
            : cell.appearance.minimumItemSpacing

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("\(#function)")
    }
}
