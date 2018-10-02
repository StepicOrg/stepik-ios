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
    func loadContent(request: BaseExplore.LoadContent.Request)
    func loadFullscreenCourseList(request: BaseExplore.PresentFullscreenCourseListModule.Request)
}

class BaseExploreInteractor: BaseExploreInteractorProtocol {
    let presenter: BaseExplorePresenterProtocol
    let contentLanguageService: ContentLanguageServiceProtocol

    init(
        presenter: BaseExplorePresenterProtocol,
        contentLanguageService: ContentLanguageServiceProtocol
    ) {
        self.presenter = presenter
        self.contentLanguageService = contentLanguageService
    }

    func loadContent(request: BaseExplore.LoadContent.Request) {
        self.presenter.presentContent(
            response: .init(contentLanguage: self.contentLanguageService.globalContentLanguage)
        )
    }

    func loadFullscreenCourseList(request: BaseExplore.PresentFullscreenCourseListModule.Request) {
        self.presenter.presentFullscreenCourseList(
            response: .init(courseListType: request.courseListType)
        )
    }
}

extension BaseExploreInteractor: TagsOutputProtocol {
    func presentCourseList(type: TagCourseListType) {
        self.loadFullscreenCourseList(request: .init(courseListType: type))
    }
}

extension BaseExploreInteractor: CourseListCollectionOutputProtocol {
    func presentCourseList(type: CollectionCourseListType) {
        self.loadFullscreenCourseList(request: .init(courseListType: type))
    }
}

extension BaseExploreInteractor: CourseListOutputProtocol {
    func presentCourseInfo(course: Course) {
        self.presenter.presentCourseInfo(response: .init(course: course))
    }

    func presentCourseSyllabus(course: Course) {
        self.presenter.presentCourseSyllabus(response: .init(course: course))
    }

    func presentLastStep(course: Course, isAdaptive: Bool) {
        self.presenter.presentLastStep(response: .init(course: course, isAdaptive: isAdaptive))
    }

    func presentEmptyState(sourceModule: CourseListInputProtocol) {

    }

    func presentError(sourceModule: CourseListInputProtocol) {
    }
}
