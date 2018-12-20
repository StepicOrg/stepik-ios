//
//  SplitTestGroupsListSplitTestGroupsListPresenter.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol SplitTestGroupsListPresenterProtocol {
    func presentSomething(response: SplitTestGroupsList.Something.Response)
}

final class SplitTestGroupsListPresenter: SplitTestGroupsListPresenterProtocol {
    weak var viewController: SplitTestGroupsListViewControllerProtocol?

    func presentSomething(response: SplitTestGroupsList.Something.Response) {
        var viewModel: SplitTestGroupsList.Something.ViewModel

        switch response.result {
        case let .failure(error):
            viewModel = SplitTestGroupsList.Something.ViewModel(state: .error(message: error.localizedDescription))
        case let .success(result):
            if result.isEmpty {
                viewModel = SplitTestGroupsList.Something.ViewModel(state: .emptyResult)
            } else {
                viewModel = SplitTestGroupsList.Something.ViewModel(state: .result(data: result))
            }
        }

        viewController?.displaySomething(viewModel: viewModel)
    }
}
