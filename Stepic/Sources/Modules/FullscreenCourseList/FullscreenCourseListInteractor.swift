//
//  FullscreenCourseListFullscreenCourseListInteractor.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol FullscreenCourseListInteractorProtocol: CourseListOutputProtocol {
    func doOnlineModeSetting(request: FullscreenCourseList.TryToSetOnline.Request)
}

final class FullscreenCourseListInteractor: FullscreenCourseListInteractorProtocol {
    let presenter: FullscreenCourseListPresenterProtocol
    let networkReachabilityService: NetworkReachabilityServiceProtocol

    init(
        presenter: FullscreenCourseListPresenterProtocol,
        networkReachabilityService: NetworkReachabilityServiceProtocol
    ) {
        self.presenter = presenter
        self.networkReachabilityService = networkReachabilityService
    }

    func tryToSetOnlineMode(request: FullscreenCourseList.TryToSetOnline.Request) {
        if self.networkReachabilityService.isReachable {
            request.module.setOnlineStatus()
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

    func presentEmptyState(sourceModule: CourseListInputProtocol) {
        self.presenter.presentEmptyState()
    }

    func presentError(sourceModule: CourseListInputProtocol) {
        self.presenter.presentErrorState()
    }
}
