//
//  CourseInfoTabSyllabusCourseInfoTabSyllabusPresenter.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright 2018 stepik-ios. All rights reserved.
//

import UIKit

protocol CourseInfoTabSyllabusPresenterProtocol {
    func presentCourseSyllabus(response: CourseInfoTabSyllabus.ShowSyllabus.Response)
}

final class CourseInfoTabSyllabusPresenter: CourseInfoTabSyllabusPresenterProtocol {
    weak var viewController: CourseInfoTabSyllabusViewControllerProtocol?

    func presentCourseSyllabus(response: CourseInfoTabSyllabus.ShowSyllabus.Response) {
        var viewModel: CourseInfoTabSyllabus.ShowSyllabus.ViewModel

        switch response.result {
        case let .success(result):
            let viewModels: [CourseInfoTabSyllabusSectionViewModel] = []
            viewModel = CourseInfoTabSyllabus.ShowSyllabus.ViewModel(state: .result(data: viewModels))
        default:
            break
        }

        // viewController?.displaySomething(viewModel: viewModel)
    }
}
