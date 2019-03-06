//
//  BaseExploreBaseExplorePresenter.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 02/10/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol BaseExplorePresenterProtocol {
    func presentFullscreenCourseList(response: BaseExplore.PresentFullscreenCourseListModule.Response)
    func presentCourseInfo(response: BaseExplore.PresentCourseInfo.Response)
    func presentCourseSyllabus(response: BaseExplore.PresentCourseSyllabus.Response)
    func presentLastStep(response: BaseExplore.PresentLastStep.Response)
    func presentAuthorization(response: BaseExplore.PresentAuthorization.Response)
}

class BaseExplorePresenter: BaseExplorePresenterProtocol {
    weak var viewController: BaseExploreViewControllerProtocol?

    func presentFullscreenCourseList(response: BaseExplore.PresentFullscreenCourseListModule.Response) {
        self.viewController?.displayFullscreenCourseList(
            viewModel: .init(
                presentationDescription: response.presentationDescription,
                courseListType: response.courseListType
            )
        )
    }

    func presentCourseInfo(response: BaseExplore.PresentCourseInfo.Response) {
        self.viewController?.displayCourseInfo(viewModel: .init(courseID: response.course.id))
    }

    func presentCourseSyllabus(response: BaseExplore.PresentCourseSyllabus.Response) {
        self.viewController?.displayCourseSyllabus(viewModel: .init(courseID: response.course.id))
    }

    func presentLastStep(response: BaseExplore.PresentLastStep.Response) {
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
