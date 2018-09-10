//
//  ExploreExplorePresenter.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ExplorePresenterProtocol {
    func presentSomething(response: Explore.Something.Response)
}

final class ExplorePresenter: ExplorePresenterProtocol {
    weak var viewController: ExploreViewControllerProtocol?

    func presentSomething(response: Explore.Something.Response) {
        var viewModel: Explore.Something.ViewModel

        switch response.result {
        case let .failure(error):
            viewModel = Explore.Something.ViewModel(state: .error(message: error.localizedDescription))
        case let .success(result):
            if result.isEmpty {
                viewModel = Explore.Something.ViewModel(state: .emptyResult)
            } else {
                viewModel = Explore.Something.ViewModel(state: .result(data: result))
            }
        }

        viewController?.displaySomething(viewModel: viewModel)
    }
}
