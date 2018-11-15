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
    func doSomeAction(request: CourseInfoTabInfo.Something.Request)
}

final class CourseInfoTabInfoInteractor: CourseInfoTabInfoInteractorProtocol, CourseInfoTabInfoInputProtocol {
    let presenter: CourseInfoTabInfoPresenterProtocol
    let provider: CourseInfoTabInfoProviderProtocol

    var course: Course? {
        didSet {
            self.doSomeAction(request: .init())
        }
    }

    init(
        presenter: CourseInfoTabInfoPresenterProtocol,
        provider: CourseInfoTabInfoProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    // MARK: Do some action

    func doSomeAction(request: CourseInfoTabInfo.Something.Request) {
        self.provider.fetchSomeItems().done { items in
            self.presenter.presentSomething(
                response: CourseInfoTabInfo.Something.Response(result: .success(items))
            )
        }.catch { _ in
            self.presenter.presentSomething(
                response: CourseInfoTabInfo.Something.Response(result: .failure(Error.fetchFailed))
            )
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
