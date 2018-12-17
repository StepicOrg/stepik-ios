//
//  CourseInfoTabSyllabusCourseInfoTabSyllabusInteractor.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright 2018 stepik-ios. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseInfoTabSyllabusInteractorProtocol {
    func getCourseSyllabus()
}

final class CourseInfoTabSyllabusInteractor: CourseInfoTabSyllabusInteractorProtocol {
    let presenter: CourseInfoTabSyllabusPresenterProtocol
    let provider: CourseInfoTabSyllabusProviderProtocol

    private var currentCourse: Course?
    private var isOnline = false

    init(
        presenter: CourseInfoTabSyllabusPresenterProtocol,
        provider: CourseInfoTabSyllabusProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func getCourseSyllabus() {
        self.presenter.presentCourseSyllabus(response: .init(result: .success(self.currentCourse!)))
    }
}

extension CourseInfoTabSyllabusInteractor: CourseInfoTabSyllabusInputProtocol {
    func update(with course: Course, isOnline: Bool) {
        self.currentCourse = course
        self.isOnline = isOnline
        self.getCourseSyllabus()
    }
}
