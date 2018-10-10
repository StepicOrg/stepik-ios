//
//  BaseExploreBaseExploreInteractor.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 02/10/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol BaseExploreInteractorProtocol {
    func loadFullscreenCourseList(request: BaseExplore.PresentFullscreenCourseListModule.Request)
    func tryToSetOnlineMode(request: BaseExplore.TryToSetOnline.Request)
}

class BaseExploreInteractor: BaseExploreInteractorProtocol, CourseListOutputProtocol {
    let presenter: BaseExplorePresenterProtocol
    let contentLanguageService: ContentLanguageServiceProtocol
    let networkReachabilityService: NetworkReachabilityServiceProtocol

    init(
        presenter: BaseExplorePresenterProtocol,
        contentLanguageService: ContentLanguageServiceProtocol,
        networkReachabilityService: NetworkReachabilityServiceProtocol
    ) {
        self.presenter = presenter
        self.contentLanguageService = contentLanguageService
        self.networkReachabilityService = networkReachabilityService
    }

    func loadFullscreenCourseList(request: BaseExplore.PresentFullscreenCourseListModule.Request) {
        self.presenter.presentFullscreenCourseList(
            response: .init(
                presentationDescription: request.presentationDescription,
                courseListType: request.courseListType
            )
        )
    }

    func tryToSetOnlineMode(request: BaseExplore.TryToSetOnline.Request) {
        if self.networkReachabilityService.isReachable {
            for module in request.modules {
                module.setOnlineStatus()
            }
        }
    }

    // MARK: - CourseListOutputProtocol

    func presentCourseInfo(course: Course) {
        self.presenter.presentCourseInfo(response: .init(course: course))
    }

    func presentCourseSyllabus(course: Course) {
        self.presenter.presentCourseSyllabus(response: .init(course: course))
    }

    func presentLastStep(course: Course, isAdaptive: Bool) {
        self.presenter.presentLastStep(response: .init(course: course, isAdaptive: isAdaptive))
    }

    func presentAuthorization() {
        self.presenter.presentAuthorization()
    }

    func presentError(sourceModule: CourseListInputProtocol) { }

    func presentEmptyState(sourceModule: CourseListInputProtocol) { }
}
