//
//  ContinueCourseContinueCoursePresenter.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ContinueCoursePresenterProtocol {
    func presentSomething(response: ContinueCourse.Something.Response)
}

final class ContinueCoursePresenter: ContinueCoursePresenterProtocol {
    weak var viewController: ContinueCourseViewControllerProtocol?

    func presentSomething(response: ContinueCourse.Something.Response) {
        var viewModel: ContinueCourse.Something.ViewModel

        switch response.result {
        case let .failure(error):
            viewModel = ContinueCourse.Something.ViewModel(state: .error(message: error.localizedDescription))
        case let .success(result):
            if result.isEmpty {
                viewModel = ContinueCourse.Something.ViewModel(state: .emptyResult)
            } else {
                viewModel = ContinueCourse.Something.ViewModel(state: .result(data: result))
            }
        }

        viewController?.displaySomething(viewModel: viewModel)
    }
}
