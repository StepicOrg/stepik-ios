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
}

final class ExploreInteractor: ExploreInteractorProtocol {
    let presenter: ExplorePresenterProtocol
    let contentLanguageService: ContentLanguageServiceProtocol

    init(
        presenter: ExplorePresenterProtocol,
        contentLanguageService: ContentLanguageServiceProtocol
    ) {
        self.presenter = presenter
        self.contentLanguageService = contentLanguageService
    }

    func loadContent(request: Explore.LoadContent.Request) {
        print("AAA", self.contentLanguageService.globalContentLanguage)
        self.presenter.presentContent(
            response: .init(contentLanguage: self.contentLanguageService.globalContentLanguage)
        )
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
