//
//  CourseInfoTabReviewsTableViewDataSource.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import UIKit

final class CourseInfoTabReviewsTableViewDataSource: NSObject, UITableViewDataSource {
    var viewModels: [CourseInfoTabReviewsViewModel]

    init(viewModels: [CourseInfoTabReviewsViewModel] = []) {
        self.viewModels = viewModels
        super.init()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseInfoTabReviewsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

        let viewModel = self.viewModels[indexPath.row]
        cell.configure(viewModel: viewModel)
        return cell
    }
}
