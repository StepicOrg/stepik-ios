//
//  CourseListPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol CourseListPresenterProtocol: class {
    func presentCourses(response: CourseList.ShowCourses.Response)
}

final class CourseListPresenter: CourseListPresenterProtocol {
    weak var viewController: CourseListViewControllerProtocol?

    func presentCourses(response: CourseList.ShowCourses.Response) {
        var viewModel: CourseList.ShowCourses.ViewModel

        switch response.result {
        case let .failure(error):
            viewModel = CourseList.ShowCourses.ViewModel(state: .emptyResult)
        case let .success(result):
            let courses = result.courses.map { CourseWidgetViewModel(course: $0) }
            if courses.isEmpty {
                viewModel = CourseList.ShowCourses.ViewModel(state: .emptyResult)
            } else {
                viewModel = CourseList.ShowCourses.ViewModel(state: .result(courses: courses))
            }
        }
    }
}
