//
//  ContinueCourseContinueCourseInteractor.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol ContinueCourseInteractorProtocol {
    func loadLastCourse(request: ContinueCourse.LoadLastCourse.Request)
    func continueLastCourse(request: ContinueCourse.ContinueCourse.Request)
}

final class ContinueCourseInteractor: ContinueCourseInteractorProtocol {
    let presenter: ContinueCoursePresenterProtocol
    let provider: ContinueCourseProviderProtocol
    let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    weak var moduleOutput: ContinueCourseOutputProtocol?

    private var currentCourse: Course?

    init(
        presenter: ContinueCoursePresenterProtocol,
        provider: ContinueCourseProviderProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.adaptiveStorageManager = adaptiveStorageManager
    }

    func loadLastCourse(request: ContinueCourse.LoadLastCourse.Request) {
        self.provider.fetchLastCourse().done { course in
            if let course = course {
                self.currentCourse = course
                self.presenter.presentLastCourse(response: .init(result: course))
            } else {
                self.moduleOutput?.hideContinueCourse()
            }
        }.catch { _ in
            self.moduleOutput?.hideContinueCourse()
        }
    }

    func continueLastCourse(request: ContinueCourse.ContinueCourse.Request) {
        guard let currentCourse = self.currentCourse else {
            return
        }

        let isAdaptive = self.adaptiveStorageManager.canOpenInAdaptiveMode(
            courseId: currentCourse.id
        )
        self.moduleOutput?.presentLastStep(
            course: currentCourse,
            isAdaptive: isAdaptive
        )
    }
}
