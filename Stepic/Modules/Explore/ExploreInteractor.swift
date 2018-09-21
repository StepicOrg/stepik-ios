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

    enum Error: Swift.Error {
        case fetchFailed
    }
}
