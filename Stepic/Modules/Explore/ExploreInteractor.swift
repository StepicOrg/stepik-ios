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
    func doSomeAction(request: Explore.Something.Request)
}

final class ExploreInteractor: ExploreInteractorProtocol {
    let presenter: ExplorePresenterProtocol
    let provider: ExploreProviderProtocol

    init(
        presenter: ExplorePresenterProtocol,
        provider: ExploreProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    // MARK: Do some action

    func doSomeAction(request: Explore.Something.Request) {
        self.provider.fetchSomeItems().done { items in
            self.presenter.presentSomething(
                response: Explore.Something.Response(result: .success(items))
            )
        }.catch { _ in
            self.presenter.presentSomething(
                response: Explore.Something.Response(result: .failure(Error.fetchFailed))
            )
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
