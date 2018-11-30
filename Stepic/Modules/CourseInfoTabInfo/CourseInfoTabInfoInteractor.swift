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
    func getCourseInfo()
    func doCourseAction()
}

final class CourseInfoTabInfoInteractor: CourseInfoTabInfoInteractorProtocol {
    weak var moduleOutput: CourseInfoTabInfoOutputProtocol?

    let presenter: CourseInfoTabInfoPresenterProtocol
    let provider: CourseInfoTabInfoProviderProtocol

    private var course: Course? {
        didSet {
            self.getCourseInfo()
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

    func getCourseInfo() {
        guard let course = self.course else {
            return
        }

        self.provider.fetchCourseUsers(course).done { course in
            self.presenter.presentCourseInfo(
                response: .init(course: self.course)
            )
        }.catch { error in
            print("Failed get course info with error: \(error)")
        }
    }

    // MARK: Course action

    func doCourseAction() {
        if let course = self.course {
            self.moduleOutput?.doCourseAction(course: course)
        }
    }
}

// MARK: - CourseInfoTabInfoInteractor: CourseInfoTabInfoInputProtocol -

extension CourseInfoTabInfoInteractor: CourseInfoTabInfoInputProtocol {
    func update(with course: Course) {
        self.course = course
    }
}
