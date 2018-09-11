//
//  TagsTagsInteractor.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol TagsInteractorProtocol {
    func doSomeAction(request: Tags.Something.Request)
}

final class TagsInteractor: TagsInteractorProtocol {
    let presenter: TagsPresenterProtocol
    let provider: TagsProviderProtocol

    init(
        presenter: TagsPresenterProtocol, 
        provider: TagsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }
    
    // MARK: Do some action

    func doSomeAction(request: Tags.Something.Request) {
        self.provider.fetchSomeItems().done { items in
            self.presenter.presentSomething(
                response: Tags.Something.Response(result: .success(items))
            )
        }.catch { error in
            self.presenter.presentSomething(
                response: Tags.Something.Response(result: .failure(Error.fetchFailed))
            )
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}