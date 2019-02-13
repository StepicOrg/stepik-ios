//
//  CourseInfoTabReviewsInteractor.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseInfoTabReviewsInteractorProtocol: class {

}

final class CourseInfoTabReviewsInteractor: CourseInfoTabReviewsInteractorProtocol {
    let presenter: CourseInfoTabReviewsPresenterProtocol

    init(presenter: CourseInfoTabReviewsPresenterProtocol) {
        self.presenter = presenter
    }
}
