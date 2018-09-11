//
//  TagsTagsPresenter.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol TagsPresenterProtocol {
    func presentSomething(response: Tags.Something.Response)
}

final class TagsPresenter: TagsPresenterProtocol {
    weak var viewController: TagsViewControllerProtocol?

    func presentSomething(response: Tags.Something.Response) {
        var viewModel: Tags.Something.ViewModel
        
        switch response.result {
        case let .failure(error):
            viewModel = Tags.Something.ViewModel(state: .error(message: error.localizedDescription))
        case let .success(result):
            if result.isEmpty {
                viewModel = Tags.Something.ViewModel(state: .emptyResult)
            } else {
                viewModel = Tags.Something.ViewModel(state: .result(data: result))
            }
        }
        
        viewController?.displaySomething(viewModel: viewModel)
    }
}