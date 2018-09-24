//
//  ExploreExploreInteractor.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExploreInteractorProtocol {
    func loadContent(request: Explore.LoadContent.Request)
    func loadLanguageSwitchBlock(request: Explore.CheckLanguageSwitchAvailability.Request)

    func loadFullscreenCourseList(request: Explore.PresentFullscreenCourseListModule.Request)
}

final class ExploreInteractor: ExploreInteractorProtocol {
    let presenter: ExplorePresenterProtocol
    let contentLanguageService: ContentLanguageServiceProtocol
    let contentLanguageSwitchAvailabilityService: ContentLanguageSwitchAvailabilityServiceProtocol

    init(
        presenter: ExplorePresenterProtocol,
        contentLanguageService: ContentLanguageServiceProtocol,
        languageSwitchAvailabilityService: ContentLanguageSwitchAvailabilityServiceProtocol
    ) {
        self.presenter = presenter
        self.contentLanguageService = contentLanguageService
        self.contentLanguageSwitchAvailabilityService = languageSwitchAvailabilityService
    }

    func loadContent(request: Explore.LoadContent.Request) {
        self.presenter.presentContent(
            response: .init(contentLanguage: self.contentLanguageService.globalContentLanguage)
        )
    }

    func loadLanguageSwitchBlock(request: Explore.CheckLanguageSwitchAvailability.Request) {
        self.presenter.presentLanguageSwitchBlock(
            response: .init(
                isHidden: self.contentLanguageSwitchAvailabilityService
                    .shouldShowLanguageSwitchOnExplore
            )
        )
        self.contentLanguageSwitchAvailabilityService.shouldShowLanguageSwitchOnExplore = false
    }

    func loadFullscreenCourseList(request: Explore.PresentFullscreenCourseListModule.Request) {
        self.presenter.presentFullscreenCourseList(
            response: .init(courseListType: request.courseListType)
        )
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension ExploreInteractor: TagsOutputProtocol {
    func presentCourseList(type: TagCourseListType) {
        self.loadFullscreenCourseList(request: .init(courseListType: type))
    }
}

extension ExploreInteractor: CourseListCollectionOutputProtocol {
    func presentCourseList(type: CollectionCourseListType) {
        self.loadFullscreenCourseList(request: .init(courseListType: type))
    }
}
