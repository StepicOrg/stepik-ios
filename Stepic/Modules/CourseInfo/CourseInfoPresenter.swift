//
//  CourseInfoCourseInfoPresenter.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 30/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol CourseInfoPresenterProtocol {
    func presentSomething(response: CourseInfo.Something.Response)
}

final class CourseInfoPresenter: CourseInfoPresenterProtocol {
    weak var viewController: CourseInfoViewControllerProtocol?

    func presentSomething(response: CourseInfo.Something.Response) {
        var viewModel: CourseInfo.Something.ViewModel

        switch response.result {
        case let .failure(error):
            viewModel = CourseInfo.Something.ViewModel(state: .error(message: error.localizedDescription))
        case let .success(result):
            if result.isEmpty {
                viewModel = CourseInfo.Something.ViewModel(state: .emptyResult)
            } else {
                viewModel = CourseInfo.Something.ViewModel(state: .result(data: result))
            }
        }

        //viewController?.displaySomething(viewModel: viewModel)
    }
}
