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
}

final class ContinueCourseInteractor: ContinueCourseInteractorProtocol {
    let presenter: ContinueCoursePresenterProtocol
    let provider: ContinueCourseProviderProtocol

    init(
        presenter: ContinueCoursePresenterProtocol,
        provider: ContinueCourseProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func loadLastCourse(request: ContinueCourse.LoadLastCourse.Request) {
        self.provider.fetchLastCourse().done { course in
            if let course = course {
                self.presenter.presentLastCourse(response: .init(result: course))
            } else {
                // TODO: module output
            }
        }.catch { _ in
            // TODO: error handling
        }
    }

    enum Error: Swift.Error {
        case loadLastCourseFailed
    }
}
