//
//  ActiveSplitTestsListInteractor.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

protocol ActiveSplitTestsListInteractorProtocol {
    func getSplitTests(request: ActiveSplitTestsList.ShowSplitTests.Request)
}

final class ActiveSplitTestsListInteractor: ActiveSplitTestsListInteractorProtocol {
    let presenter: ActiveSplitTestsListPresenterProtocol
    let provider: ActiveSplitTestsListProviderProtocol

    init(
        presenter: ActiveSplitTestsListPresenterProtocol,
        provider: ActiveSplitTestsListProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func getSplitTests(request: ActiveSplitTestsList.ShowSplitTests.Request) {
        let splitTests = self.provider.getActiveSplitTests()
        self.presenter.presentSplitTests(response: .init(splitTests: splitTests))
    }
}
