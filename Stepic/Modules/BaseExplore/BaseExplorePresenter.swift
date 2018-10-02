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

    func presentContent(response: BaseExplore.LoadContent.Response)
    func presentCourseInfo(response: BaseExplore.PresentCourseInfo.Response)
    func presentCourseSyllabus(response: BaseExplore.PresentCourseSyllabus.Response)
    func presentLastStep(response: BaseExplore.PresentLastStep.Response)
}

class BaseExplorePresenter: BaseExplorePresenterProtocol {
    weak var viewController: BaseExploreViewControllerProtocol?

    func presentContent(response: BaseExplore.LoadContent.Response) {
        self.viewController?.displayContent(
            viewModel: .init(state: .normal(contentLanguage: response.contentLanguage))
        )
    }

    func presentFullscreenCourseList(response: BaseExplore.PresentFullscreenCourseListModule.Response) {
        self.viewController?.displayFullscreenCourseList(
            viewModel: .init(courseListType: response.courseListType)
        )
    }

    func presentCourseInfo(response: BaseExplore.PresentCourseInfo.Response) {
        self.viewController?.displayCourseInfo(viewModel: .init(course: response.course))
    }

    func presentCourseSyllabus(response: BaseExplore.PresentCourseSyllabus.Response) {
        self.viewController?.displayCourseSyllabus(viewModel: .init(course: response.course))
    }

    func presentLastStep(response: BaseExplore.PresentLastStep.Response) {
        self.viewController?.displayLastStep(
            viewModel: .init(
                course: response.course,
                isAdaptive: response.isAdaptive
            )
        )
    }
}
