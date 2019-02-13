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
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
