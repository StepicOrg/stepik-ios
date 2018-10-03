//
//  FullscreenCourseListFullscreenCourseListInteractor.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol FullscreenCourseListInteractorProtocol: CourseListOutputProtocol { }

final class FullscreenCourseListInteractor: FullscreenCourseListInteractorProtocol {
    let presenter: FullscreenCourseListPresenterProtocol

    init(presenter: FullscreenCourseListPresenterProtocol) {
        self.presenter = presenter
    }

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

    }

    func presentError(sourceModule: CourseListInputProtocol) {

    }
}
