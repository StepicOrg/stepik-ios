//
//  ContinueCourseContinueCoursePresenter.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ContinueCoursePresenterProtocol {
    func presentLastCourse(response: ContinueCourse.LoadLastCourse.Response)
    func presentTooltip(response: ContinueCourse.CheckTooltipAvailability.Response)
}

final class ContinueCoursePresenter: ContinueCoursePresenterProtocol {
    weak var viewController: ContinueCourseViewControllerProtocol?

    func presentLastCourse(response: ContinueCourse.LoadLastCourse.Response) {
        var viewModel: ContinueCourse.LoadLastCourse.ViewModel

        viewModel = ContinueCourse.LoadLastCourse.ViewModel(
            state: .result(data: .init(course: response.result))
        )

        self.viewController?.displayLastCourse(viewModel: viewModel)
    }

    func presentTooltip(response: ContinueCourse.CheckTooltipAvailability.Response) {
        self.viewController?.displayTooltip(
            viewModel: .init(shouldShowTooltip: response.shouldShowTooltip)
        )
    }
}
