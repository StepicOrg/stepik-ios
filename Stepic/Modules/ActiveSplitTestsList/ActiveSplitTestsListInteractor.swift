//
//  ActiveSplitTestsListInteractor.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol ActiveSplitTestsListInteractorProtocol {
    func getSplitTests(request: ActiveSplitTestsList.ShowSplitTests.Request)
    func presentSplitTestGroups(request: ActiveSplitTestsList.PresentGroups.Request)
}

final class ActiveSplitTestsListInteractor: ActiveSplitTestsListInteractorProtocol {
    let presenter: ActiveSplitTestsListPresenterProtocol
    let provider: ActiveSplitTestsListProviderProtocol

    private var currentSplitTests = [String]()

    init(
        presenter: ActiveSplitTestsListPresenterProtocol,
        provider: ActiveSplitTestsListProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func getSplitTests(request: ActiveSplitTestsList.ShowSplitTests.Request) {
        self.currentSplitTests = self.provider.getActiveSplitTests()
        self.presenter.presentSplitTests(response: .init(splitTests: self.currentSplitTests))
    }

    func presentSplitTestGroups(request: ActiveSplitTestsList.PresentGroups.Request) {
        guard let splitTest = self.currentSplitTests
            .first(where: { $0 == request.uniqueIdentifier }) else {
            return
        }

        print(splitTest)
    }
}
