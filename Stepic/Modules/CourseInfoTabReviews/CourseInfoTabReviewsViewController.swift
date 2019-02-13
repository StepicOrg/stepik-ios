//
//  CourseInfoTabReviewsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import UIKit

protocol CourseInfoTabReviewsViewControllerProtocol: class {

}

final class CourseInfoTabReviewsViewController: UIViewController {
    let interactor: CourseInfoTabReviewsInteractorProtocol

    lazy var courseInfoTabReviewsView = self.view as? CourseInfoTabReviewsView

    private let tableDataSource = CourseInfoTabReviewsTableViewDataSource()

    init(interactor: CourseInfoTabReviewsInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableDataSource.viewModels = [
            CourseInfoTabReviewsViewModel(userName: "1", dateRepresentation: "2", text: "Test", avatarImageURL: URL(string: "https://stepik.org/users/38651314/251c06002a701e6d6991dac7ff9dc90b83d1e7b6/avatar.svg")!, score: 1),
            CourseInfoTabReviewsViewModel(userName: "1", dateRepresentation: "2", text: "Test", avatarImageURL: URL(string: "https://stepik.org/users/38651314/251c06002a701e6d6991dac7ff9dc90b83d1e7b6/avatar.svg")!, score: 1),
            CourseInfoTabReviewsViewModel(userName: "1", dateRepresentation: "2", text: "Test", avatarImageURL: URL(string: "https://stepik.org/users/38651314/251c06002a701e6d6991dac7ff9dc90b83d1e7b6/avatar.svg")!, score: 1),
            CourseInfoTabReviewsViewModel(userName: "1", dateRepresentation: "2", text: "Test", avatarImageURL: URL(string: "https://stepik.org/users/38651314/251c06002a701e6d6991dac7ff9dc90b83d1e7b6/avatar.svg")!, score: 1),
            CourseInfoTabReviewsViewModel(userName: "1", dateRepresentation: "2", text: "Test", avatarImageURL: URL(string: "https://stepik.org/users/38651314/251c06002a701e6d6991dac7ff9dc90b83d1e7b6/avatar.svg")!, score: 1)
        ]
        self.courseInfoTabReviewsView?.updateTableViewData(dataSource: self.tableDataSource)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = CourseInfoTabReviewsView()
    }
}

extension CourseInfoTabReviewsViewController: CourseInfoTabReviewsViewControllerProtocol {

}
