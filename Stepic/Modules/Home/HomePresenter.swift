//
//  HomeHomePresenter.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 17/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol HomePresenterProtocol {
    func presentSomething(response: Home.Something.Response)
}

final class HomePresenter: HomePresenterProtocol {
    weak var viewController: HomeViewControllerProtocol?

    func presentSomething(response: Home.Something.Response) {
        var viewModel: Home.Something.ViewModel

        switch response.result {
        case let .failure(error):
            viewModel = Home.Something.ViewModel(state: .error(message: error.localizedDescription))
        case let .success(result):
            if result.isEmpty {
                viewModel = Home.Something.ViewModel(state: .emptyResult)
            } else {
                viewModel = Home.Something.ViewModel(state: .result(data: result))
            }
        }

        viewController?.displaySomething(viewModel: viewModel)
    }
}
