//
//  CourseInfoTabInfoInteractor.swift
//  stepik-ios
//
//  Created by Ivan Magda on 15/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseInfoTabInfoInteractorProtocol {
    func getCourseInfo(request: CourseInfoTabInfo.ShowInfo.Request)
}

final class CourseInfoTabInfoInteractor: CourseInfoTabInfoInteractorProtocol, CourseInfoTabInfoInputProtocol {
    let presenter: CourseInfoTabInfoPresenterProtocol
    let provider: CourseInfoTabInfoProviderProtocol

    var course: Course? {
        didSet {
            self.getCourseInfo(request: .init())
        }
    }

    init(
        presenter: CourseInfoTabInfoPresenterProtocol,
        provider: CourseInfoTabInfoProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    // MARK: Get course info

    func getCourseInfo(request: CourseInfoTabInfo.ShowInfo.Request) {
        self.presenter.presentCourseInfo(
            response: .init(course: self.course)
        )
    }
}
