//
//  ContentLanguageContentLanguageInteractor.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol ContentLanguageInteractorProtocol {
    func doSomeAction(request: ContentLanguage.Something.Request)
}

final class ContentLanguageInteractor: ContentLanguageInteractorProtocol {
    let presenter: ContentLanguagePresenterProtocol
    let provider: ContentLanguageProviderProtocol

    init(
        presenter: ContentLanguagePresenterProtocol, 
        provider: ContentLanguageProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }
    
    // MARK: Do some action

    func doSomeAction(request: ContentLanguage.Something.Request) {
        self.provider.fetchSomeItems().done { items in
            self.presenter.presentSomething(
                response: ContentLanguage.Something.Response(result: .success(items))
            )
        }.catch { error in
            self.presenter.presentSomething(
                response: ContentLanguage.Something.Response(result: .failure(Error.fetchFailed))
            )
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}