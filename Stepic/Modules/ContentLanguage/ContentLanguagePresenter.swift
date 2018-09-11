//
//  ContentLanguageContentLanguagePresenter.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ContentLanguagePresenterProtocol {
    func presentSomething(response: ContentLanguage.Something.Response)
}

final class ContentLanguagePresenter: ContentLanguagePresenterProtocol {
    weak var viewController: ContentLanguageViewControllerProtocol?

    func presentSomething(response: ContentLanguage.Something.Response) {
        var viewModel: ContentLanguage.Something.ViewModel
        
        switch response.result {
        case let .failure(error):
            viewModel = ContentLanguage.Something.ViewModel(state: .error(message: error.localizedDescription))
        case let .success(result):
            if result.isEmpty {
                viewModel = ContentLanguage.Something.ViewModel(state: .emptyResult)
            } else {
                viewModel = ContentLanguage.Something.ViewModel(state: .result(data: result))
            }
        }
        
        viewController?.displaySomething(viewModel: viewModel)
    }
}