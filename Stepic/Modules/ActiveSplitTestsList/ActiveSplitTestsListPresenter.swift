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
                let splitTests = self.formattedSplitTests(response.splitTests)
                return .init(state: .result(data: splitTests))
            }
        }()

        self.viewController?.displaySplitTests(viewModel: viewModel)
    }

    private func formattedSplitTests(_ splitTests: [String]) -> [SplitTestViewModel] {
        return splitTests.map { splitTest in
            SplitTestViewModel(
                uniqueIdentifier: splitTest,
                title: splitTest.components(separatedBy: "-").last?
                    .replacingOccurrences(of: "_", with: " ").capitalized ?? splitTest
            )
        }
    }
}
