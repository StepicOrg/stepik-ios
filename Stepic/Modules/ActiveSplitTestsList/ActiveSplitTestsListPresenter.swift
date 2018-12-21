//
//  ActiveSplitTestsListPresenter.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

protocol ActiveSplitTestsListPresenterProtocol {
    func presentSplitTests(response: ActiveSplitTestsList.ShowSplitTests.Response)
}

final class ActiveSplitTestsListPresenter: ActiveSplitTestsListPresenterProtocol {
    weak var viewController: ActiveSplitTestsListViewControllerProtocol?

    func presentSplitTests(response: ActiveSplitTestsList.ShowSplitTests.Response) {
        let viewModel: ActiveSplitTestsList.ShowSplitTests.ViewModel = {
            if response.splitTests.isEmpty {
                return .init(state: .emptyResult)
            } else {
                let viewModels = response.splitTests.map { splitTest in
                    SplitTestViewModel(
                        uniqueIdentifier: splitTest.uniqueIdentifier,
                        title: splitTest.title
                    )
                }.sorted { lhs, rhs in
                    lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                }

                return .init(state: .result(data: viewModels))
            }
        }()

        self.viewController?.displaySplitTests(viewModel: viewModel)
    }
}
