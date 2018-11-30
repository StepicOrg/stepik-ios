//
//  CourseInfoCourseInfoInteractor.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 30/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseInfoInteractorProtocol {
    func doSomeAction(request: CourseInfo.Something.Request)
}

final class CourseInfoInteractor: CourseInfoInteractorProtocol {
    let presenter: CourseInfoPresenterProtocol
    let provider: CourseInfoProviderProtocol

    init(
        presenter: CourseInfoPresenterProtocol,
        provider: CourseInfoProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    // MARK: Do some action

    func doSomeAction(request: CourseInfo.Something.Request) {
        self.provider.fetchSomeItems().done { items in
            self.presenter.presentSomething(
                response: CourseInfo.Something.Response(result: .success(items))
            )
        }.catch { _ in
            self.presenter.presentSomething(
                response: CourseInfo.Something.Response(result: .failure(Error.fetchFailed))
            )
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
