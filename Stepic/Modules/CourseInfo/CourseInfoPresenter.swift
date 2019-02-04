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
    func presentAuthorization()

    func presentWaitingState()
    func dismissWaitingState()
}

final class CourseInfoPresenter: CourseInfoPresenterProtocol {
    weak var viewController: CourseInfoViewControllerProtocol?

    func presentCourse(response: CourseInfo.ShowCourse.Response) {
        switch response.result {
        case .success(let result):
            let viewModel = CourseInfo.ShowCourse.ViewModel(
                state: .result(data: CourseInfoHeaderViewModel(course: result))
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
            initIDs: initIDs,
            navigationRules: response.navigationRules,
            navigationDelegate: response.navigationDelegate
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

    func presentWaitingState() {
        self.viewController?.showBlockingLoadingIndicator()
    }

    func dismissWaitingState() {
        self.viewController?.hideBlockingLoadingIndicator()
    }

    func presentLastStep(response: CourseInfo.PresentLastStep.Response) {
        self.viewController?.displayLastStep(
            viewModel: .init(
                course: response.course,
                isAdaptive: response.isAdaptive
            )
        )
    }

    func presentAuthorization() {
        self.viewController?.displayAuthorization()
    }
}
