//
//  CourseInfoCourseInfoPresenter.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 30/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol CourseInfoPresenterProtocol {
    func presentCourse(response: CourseInfo.ShowCourse.Response)
}

final class CourseInfoPresenter: CourseInfoPresenterProtocol {
    weak var viewController: CourseInfoViewControllerProtocol?

    func presentCourse(response: CourseInfo.ShowCourse.Response) {
        var viewModel: CourseInfo.ShowCourse.ViewModel

        switch response.result {
        case .failure(let error):
            viewModel = CourseInfo.ShowCourse.ViewModel(state: .loading)
        case .success(let result):
            viewModel = CourseInfo.ShowCourse.ViewModel(
                state: .result(data: CourseInfoHeaderViewModel(course: result))
            )
        }

        self.viewController?.displayCourse(viewModel: viewModel)
    }

}
