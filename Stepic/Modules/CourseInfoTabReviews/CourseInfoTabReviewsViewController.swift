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

    init(interactor: CourseInfoTabReviewsInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
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
