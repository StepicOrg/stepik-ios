//
//  HomeHomeInteractor.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 17/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol HomeInteractorProtocol {
    func doSomeAction(request: Home.Something.Request)
}

final class HomeInteractor: HomeInteractorProtocol {
    let presenter: HomePresenterProtocol
    let provider: HomeProviderProtocol

    init(
        presenter: HomePresenterProtocol,
        provider: HomeProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    // MARK: Do some action

    func doSomeAction(request: Home.Something.Request) {
        self.provider.fetchSomeItems().done { items in
            self.presenter.presentSomething(
                response: Home.Something.Response(result: .success(items))
            )
        }.catch { _ in
            self.presenter.presentSomething(
                response: Home.Something.Response(result: .failure(Error.fetchFailed))
            )
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
