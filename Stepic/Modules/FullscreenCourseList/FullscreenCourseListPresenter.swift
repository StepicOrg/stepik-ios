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
    func presentAuthorization()
    func presentEmptyState()
    func presentErrorState()
}

final class FullscreenCourseListPresenter: FullscreenCourseListPresenterProtocol {
    weak var viewController: FullscreenCourseListViewControllerProtocol?

    func presentCourseInfo(response: FullscreenCourseList.PresentCourseInfo.Response) {
        self.viewController?.displayCourseInfo(viewModel: .init(course: response.course))
    }

    func presentCourseSyllabus(response: FullscreenCourseList.PresentCourseSyllabus.Response) {
        self.viewController?.displayCourseSyllabus(viewModel: .init(course: response.course))
    }

    func presentLastStep(response: FullscreenCourseList.PresentLastStep.Response) {
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

    func presentEmptyState() {
        self.viewController?.displayEmptyState()
    }

    func presentErrorState() {
        self.viewController?.displayErrorState()
    }
}
