//
//  CourseInfoCourseInfoPresenter.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 30/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol CourseInfoPresenterProtocol {
    func presentCourse(response: CourseInfo.ShowCourse.Response)
    func presentLesson(response: CourseInfo.ShowLesson.Response)
    func presentPersonalDeadlinesSettings(response: CourseInfo.PersonalDeadlinesSettings.Response)
    func presentExamLesson(response: CourseInfo.ShowExamLesson.Response)
    func presentCourseSharing(response: CourseInfo.ShareCourse.Response)
    func presentLastStep(response: CourseInfo.PresentLastStep.Response)
    func presentAuthorization(response: CourseInfo.PresentAuthorization.Response)
    func presentWaitingState(response: CourseInfo.HandleWaitingState.Response)
}

final class CourseInfoPresenter: CourseInfoPresenterProtocol {
    weak var viewController: CourseInfoViewControllerProtocol?

    func presentCourse(response: CourseInfo.ShowCourse.Response) {
        switch response.result {
        case .success(let result):
            let viewModel = CourseInfo.ShowCourse.ViewModel(
                state: .result(data: self.makeHeaderViewModel(course: result))
            )
            self.viewController?.displayCourse(viewModel: viewModel)
        default:
            break
        }
    }

    func presentLesson(response: CourseInfo.ShowLesson.Response) {
        let initObjects: LessonInitObjects = (
            lesson: response.lesson,
            startStepId: 0,
            context: .unit
        )

        let initIDs: LessonInitIds = (
            stepId: nil,
            unitId: response.unitID
        )

        let viewModel = CourseInfo.ShowLesson.ViewModel(
            initObjects: initObjects,
            initIDs: initIDs
        )

        self.viewController?.displayLesson(viewModel: viewModel)
    }

    func presentPersonalDeadlinesSettings(response: CourseInfo.PersonalDeadlinesSettings.Response) {
        let viewModel = CourseInfo.PersonalDeadlinesSettings.ViewModel(
            action: response.action,
            course: response.course
        )
        self.viewController?.displayPersonalDeadlinesSettings(viewModel: viewModel)
    }

    func presentExamLesson(response: CourseInfo.ShowExamLesson.Response) {
        let viewModel = CourseInfo.ShowExamLesson.ViewModel(
            urlPath: response.urlPath
        )
        self.viewController?.displayExamLesson(viewModel: viewModel)
    }

    func presentCourseSharing(response: CourseInfo.ShareCourse.Response) {
        let viewModel = CourseInfo.ShareCourse.ViewModel(
            urlPath: response.urlPath
        )
        self.viewController?.displayCourseSharing(viewModel: viewModel)
    }

    func presentWaitingState(response: CourseInfo.HandleWaitingState.Response) {
        self.viewController?.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: response.shouldDismiss))
    }

    func presentLastStep(response: CourseInfo.PresentLastStep.Response) {
        self.viewController?.displayLastStep(
            viewModel: .init(
                course: response.course,
                isAdaptive: response.isAdaptive
            )
        )
    }

    func presentAuthorization(response: CourseInfo.PresentAuthorization.Response) {
        self.viewController?.displayAuthorization(viewModel: .init())
    }

    private func makeProgressViewModel(progress: Progress) -> CourseInfoProgressViewModel {
        var normalizedPercent = progress.percentPassed
        normalizedPercent.round(.up)

        return CourseInfoProgressViewModel(
            progress: normalizedPercent / 100.0,
            progressLabelText: FormatterHelper.integerPercent(Int(normalizedPercent))
        )
    }

    private func makeHeaderViewModel(course: Course) -> CourseInfoHeaderViewModel {
        let rating: Int = {
            if let reviewsCount = course.reviewSummary?.count,
               let averageRating = course.reviewSummary?.average,
               reviewsCount > 0 {
                return Int(round(averageRating))
            }
            return 0
        }()

        let progress: CourseInfoProgressViewModel? = {
            if let progress = course.progress {
                return self.makeProgressViewModel(progress: progress)
            }
            return nil
        }()

        return CourseInfoHeaderViewModel(
            title: course.title,
            coverImageURL: URL(string: course.coverURLString),
            rating: rating,
            learnersLabelText: FormatterHelper.longNumber(course.learnersCount ?? 0),
            progress: progress,
            isVerified: (course.readiness ?? 0) > 0.9,
            isEnrolled: course.enrolled
        )
    }
}
