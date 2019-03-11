//
//  FullscreenCourseListFullscreenCourseListPresenter.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol FullscreenCourseListPresenterProtocol {
    func presentCourseInfo(response: FullscreenCourseList.PresentCourseInfo.Response)
    func presentCourseSyllabus(response: FullscreenCourseList.PresentCourseSyllabus.Response)
    func presentLastStep(response: FullscreenCourseList.PresentLastStep.Response)
    func presentAuthorization(response: FullscreenCourseList.PresentAuthorization.Response)
    func presentPlaceholder(response: FullscreenCourseList.PresentPlaceholder.Response)
}

final class FullscreenCourseListPresenter: FullscreenCourseListPresenterProtocol {
    weak var viewController: FullscreenCourseListViewControllerProtocol?

    func presentCourseInfo(response: FullscreenCourseList.PresentCourseInfo.Response) {
        self.viewController?.displayCourseInfo(viewModel: .init(courseID: response.course.id))
    }

    func presentCourseSyllabus(response: FullscreenCourseList.PresentCourseSyllabus.Response) {
        self.viewController?.displayCourseSyllabus(viewModel: .init(courseID: response.course.id))
    }

    func presentLastStep(response: FullscreenCourseList.PresentLastStep.Response) {
        self.viewController?.displayLastStep(
            viewModel: .init(
                course: response.course,
                isAdaptive: response.isAdaptive
            )
        )
    }

    func presentAuthorization(response: FullscreenCourseList.PresentAuthorization.Response) {
        self.viewController?.displayAuthorization(viewModel: .init())
    }

    func presentPlaceholder(response: FullscreenCourseList.PresentPlaceholder.Response) {
        self.viewController?.displayPlaceholder(viewModel: .init(state: response.state))
    }
}
