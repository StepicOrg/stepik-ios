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

        let result = response.result
        let courses = self.makeWidgetViewModels(
            courses: result.fetchedCourses.courses,
            availableInAdaptive: result.availableAdaptiveCourses
        )

        let data = CourseList.ListData(
            courses: courses,
            hasNextPage: result.fetchedCourses.hasNextPage
        )
        viewModel = CourseList.ShowCourses.ViewModel(state: .result(data: data))

        self.viewController?.displayCourses(viewModel: viewModel)
    }

    func presentNextCourses(response: CourseList.LoadNextCourses.Response) {
        var viewModel: CourseList.LoadNextCourses.ViewModel

        let result = response.result
        let courses = self.makeWidgetViewModels(
            courses: result.fetchedCourses.courses,
            availableInAdaptive: result.availableAdaptiveCourses
        )
        let data = CourseList.ListData(
            courses: courses,
            hasNextPage: result.fetchedCourses.hasNextPage
        )
        viewModel = CourseList.LoadNextCourses.ViewModel(state: .result(data: data))

        self.viewController?.displayNextCourses(viewModel: viewModel)
    }

    func presentWaitingState() {
        self.viewController?.showBlockingLoadingIndicator()
    }

    func dismissWaitingState() {
        self.viewController?.hideBlockingLoadingIndicator()
    }

    private func makeWidgetViewModels(
        courses: [(UniqueIdentifierType, Course)],
        availableInAdaptive: Set<Course>
    ) -> [CourseWidgetViewModel] {
        var viewModels: [CourseWidgetViewModel] = []
        for (uid, course) in courses {
            var viewModel = CourseWidgetViewModel(
                uniqueIdentifier: uid,
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
