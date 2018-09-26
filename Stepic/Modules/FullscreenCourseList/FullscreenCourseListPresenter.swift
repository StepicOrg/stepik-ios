//
//  FullscreenCourseListFullscreenCourseListPresenter.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol FullscreenCourseListPresenterProtocol {
    func presentSomething(response: FullscreenCourseList.Something.Response)
}

final class FullscreenCourseListPresenter: FullscreenCourseListPresenterProtocol {
    weak var viewController: FullscreenCourseListViewControllerProtocol?

    func presentSomething(response: FullscreenCourseList.Something.Response) {
        var viewModel: FullscreenCourseList.Something.ViewModel

        switch response.result {
        case .failure(let error):
            viewModel = FullscreenCourseList.Something.ViewModel(state: .error(message: error.localizedDescription))
        case .success(let result):
            if result.isEmpty {
                viewModel = FullscreenCourseList.Something.ViewModel(state: .emptyResult)
            } else {
                viewModel = FullscreenCourseList.Something.ViewModel(state: .result(data: result))
            }
        }

        viewController?.displaySomething(viewModel: viewModel)
    }
}
