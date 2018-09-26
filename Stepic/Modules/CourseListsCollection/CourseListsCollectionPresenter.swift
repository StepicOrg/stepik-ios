//
//  CourseListsCollectionPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseListsCollectionPresenterProtocol: class {
    func presentCourses(response: CourseListsCollection.ShowCourseLists.Response)
}

final class CourseListsCollectionPresenter: CourseListsCollectionPresenterProtocol {
    weak var viewController: CourseListsCollectionViewControllerProtocol?

    func presentCourses(response: CourseListsCollection.ShowCourseLists.Response) {
        var viewModel: CourseListsCollection.ShowCourseLists.ViewModel

        switch response.result {
        case .failure(let error):
            viewModel = CourseListsCollection.ShowCourseLists.ViewModel(state: .emptyResult)
        case .success(let result):
            let courses = result.map { CourseListsCollectionViewModel(courseList: $0) }
            if courses.isEmpty {
                viewModel = CourseListsCollection.ShowCourseLists.ViewModel(state: .emptyResult)
            } else {
                viewModel = CourseListsCollection.ShowCourseLists.ViewModel(state: .result(data: courses))
            }
        }

        self.viewController?.displayCourseLists(viewModel: viewModel)
    }
}
