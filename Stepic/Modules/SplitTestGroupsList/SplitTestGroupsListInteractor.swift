//
//  SplitTestGroupsListSplitTestGroupsListInteractor.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol SplitTestGroupsListInteractorProtocol {
    func doSomeAction(request: SplitTestGroupsList.Something.Request)
}

final class SplitTestGroupsListInteractor: SplitTestGroupsListInteractorProtocol {
    let presenter: SplitTestGroupsListPresenterProtocol
    let provider: SplitTestGroupsListProviderProtocol

    init(
        presenter: SplitTestGroupsListPresenterProtocol,
        provider: SplitTestGroupsListProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    // MARK: Do some action

    func doSomeAction(request: SplitTestGroupsList.Something.Request) {
        self.provider.fetchSomeItems().done { items in
            self.presenter.presentSomething(
                response: SplitTestGroupsList.Something.Response(result: .success(items))
            )
        }.catch { _ in
            self.presenter.presentSomething(
                response: SplitTestGroupsList.Something.Response(result: .failure(Error.fetchFailed))
            )
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
