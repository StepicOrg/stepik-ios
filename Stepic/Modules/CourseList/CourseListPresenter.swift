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
    func presentNextCourses(response: CourseList.LoadNextCourses.Response)

    func presentWaitingState()
    func dismissWaitingState()
}

final class CourseListPresenter: CourseListPresenterProtocol {
    weak var viewController: CourseListViewControllerProtocol?

    func presentCourses(response: CourseList.ShowCourses.Response) {
        var viewModel: CourseList.ShowCourses.ViewModel

        switch response.result {
        case .failure(let error):
            viewModel = CourseList.ShowCourses.ViewModel(state: .emptyResult)
        case .success(let result):
            let courses = self.makeWidgetViewModels(
                courses: result.fetchedCourses.courses,
                availableInAdaptive: result.availableAdaptiveCourses
            )
            if courses.isEmpty {
                viewModel = CourseList.ShowCourses.ViewModel(state: .emptyResult)
            } else {
                let data = CourseList.ListData(
                    courses: courses,
                    hasNextPage: result.fetchedCourses.hasNextPage
                )
                viewModel = CourseList.ShowCourses.ViewModel(state: .result(data: data))
            }
        }

        self.viewController?.displayCourses(viewModel: viewModel)
    }

    func presentNextCourses(response: CourseList.LoadNextCourses.Response) {
        var viewModel: CourseList.LoadNextCourses.ViewModel

        switch response.result {
        case .failure(let error):
            viewModel = CourseList.LoadNextCourses.ViewModel(state: .error(message: "Error"))
        case .success(let result):
            let courses = self.makeWidgetViewModels(
                courses: result.fetchedCourses.courses,
                availableInAdaptive: result.availableAdaptiveCourses
            )
            let data = CourseList.ListData(
                courses: courses,
                hasNextPage: result.fetchedCourses.hasNextPage
            )
            viewModel = CourseList.LoadNextCourses.ViewModel(state: .result(data: data))
        }

        self.viewController?.displayNextCourses(viewModel: viewModel)
    }

    func presentWaitingState() {
        self.viewController?.showBlockingLoadingIndicator()
    }

    func dismissWaitingState() {
        self.viewController?.hideBlockingLoadingIndicator()
    }

    private func makeWidgetViewModels(
        courses: [Course],
        availableInAdaptive: Set<Course>
    ) -> [CourseWidgetViewModel] {
        var viewModels: [CourseWidgetViewModel] = []
        for (index, course) in courses.enumerated() {
            var viewModel = CourseWidgetViewModel(
                uniqueIdentifier: "\(index)",
                course: course
            )
            let isAdaptive = availableInAdaptive.contains(course)

            let buttonDescriptionFactory = ButtonDescriptionFactory(course: course)
            viewModel.primaryButtonDescription = buttonDescriptionFactory.makePrimary()
            viewModel.secondaryButtonDescription = buttonDescriptionFactory.makeSecondary(
                isAdaptive: isAdaptive
            )

            viewModel.isAdaptive = isAdaptive
            viewModels.append(viewModel)
        }
        return viewModels
    }
}
