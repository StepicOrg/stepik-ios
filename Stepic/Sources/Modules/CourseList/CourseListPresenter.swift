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
    func presentWaitingState(response: CourseList.HandleWaitingState.Response)
}

final class CourseListPresenter: CourseListPresenterProtocol {
    weak var viewController: CourseListViewControllerProtocol?

    func presentCourses(response: CourseList.ShowCourses.Response) {
        var viewModel: CourseList.ShowCourses.ViewModel

        let courses = self.makeWidgetViewModels(
            courses: response.result.fetchedCourses.courses,
            availableInAdaptive: response.result.availableAdaptiveCourses,
            isAuthorized: response.isAuthorized
        )

        let data = CourseList.ListData(
            courses: courses,
            hasNextPage: response.result.fetchedCourses.hasNextPage
        )
        viewModel = CourseList.ShowCourses.ViewModel(state: .result(data: data))

        self.viewController?.displayCourses(viewModel: viewModel)
    }

    func presentNextCourses(response: CourseList.LoadNextCourses.Response) {
        var viewModel: CourseList.LoadNextCourses.ViewModel

        let courses = self.makeWidgetViewModels(
            courses: response.result.fetchedCourses.courses,
            availableInAdaptive: response.result.availableAdaptiveCourses,
            isAuthorized: response.isAuthorized
        )
        let data = CourseList.ListData(
            courses: courses,
            hasNextPage: response.result.fetchedCourses.hasNextPage
        )
        viewModel = CourseList.LoadNextCourses.ViewModel(state: .result(data: data))

        self.viewController?.displayNextCourses(viewModel: viewModel)
    }

    func presentWaitingState(response: CourseInfoTabSyllabus.HandleWaitingState.Response) {
        self.viewController?.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: response.shouldDismiss))
    }

    private func makeWidgetViewModels(
        courses: [(UniqueIdentifierType, Course)],
        availableInAdaptive: Set<Course>,
        isAuthorized: Bool
    ) -> [CourseWidgetViewModel] {
        var viewModels: [CourseWidgetViewModel] = []
        for (uid, course) in courses {
            let isAdaptive = availableInAdaptive.contains(course)
            let viewModel = CourseWidgetViewModel(
                uniqueIdentifier: uid,
                course: course,
                isAdaptive: isAdaptive,
                isAuthorized: isAuthorized
            )
            viewModels.append(viewModel)
        }
        return viewModels
    }

    private func makeProgressViewModel(progress: Progress) -> CourseWidgetProgressViewModel {
        var normalizedPercent = progress.percentPassed
        normalizedPercent.round(.up)

        return CourseWidgetProgressViewModel(
            progress: normalizedPercent / 100.0,
            progressLabelText: FormatterHelper.integerPercent(Int(normalizedPercent))
        )
    }

    private func makeWidgetViewModel(
        uniqueIdentifier: UniqueIdentifierType,
        course: Course,
        isAdaptive: Bool,
        isAuthorized: Bool
    ) -> CourseWidgetViewModel {
        var progressViewModel: CourseWidgetProgressViewModel?
        if let progress = course.progress {
            progressViewModel = CourseWidgetProgressViewModel(progress: progress)
        }

        var ratingLabelText: String?
        if let reviewsCount = course.reviewSummary?.count,
           let averageRating = course.reviewSummary?.average,
           reviewsCount > 0 {
            ratingLabelText = FormatterHelper.averageRating(averageRating)
        }

        let primaryButtonText = self.makePrimaryButtonDescription(
            isEnrolled: course.enrolled,
            isAuthorized: isAuthorized
        )
        let secondaryButtonText = self.makeSecondaryButtonDescription(
            isEnrolled: course.enrolled,
            isAdaptive: isAdaptive
        )

        return CourseWidgetViewModel(
            title: course.title,
            coverImageURL: URL(string: course.coverURLString),
            primaryButtonDescription: primaryButtonText,
            secondaryButtonDescription: secondaryButtonText,
            learnersLabelText: FormatterHelper.longNumber(course.learnersCount ?? 0),
            ratingLabelText: ratingLabelText,
            isAdaptive: isAdaptive,
            progress: progressViewModel,
            uniqueIdentifier: uniqueIdentifier
        )
    }

    func makePrimaryButtonDescription(isEnrolled: Bool, isAuthorized: Bool) -> CourseWidgetViewModel.ButtonDescription {
        let joinTitle = NSLocalizedString("WidgetButtonJoin", comment: "")

        let title = isEnrolled && isAuthorized
            ? NSLocalizedString("WidgetButtonLearn", comment: "")
            : joinTitle
        return CourseWidgetViewModel.ButtonDescription(
            title: title,
            isCallToAction: !isEnrolled || !isAuthorized
        )
    }

    private func makeSecondaryButtonDescription(
        isEnrolled: Bool,
        isAdaptive: Bool
    ) -> CourseWidgetViewModel.ButtonDescription {
        var title: String
        if isAdaptive {
            title = NSLocalizedString("WidgetButtonInfo", comment: "")
        } else {
            title = isEnrolled
                ? NSLocalizedString("WidgetButtonSyllabus", comment: "")
                : NSLocalizedString("WidgetButtonInfo", comment: "")
        }
        return CourseWidgetViewModel.ButtonDescription(
            title: title,
            isCallToAction: false
        )
    }
}