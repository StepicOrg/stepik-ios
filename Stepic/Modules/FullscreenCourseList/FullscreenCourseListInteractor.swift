//
//  FullscreenCourseListFullscreenCourseListInteractor.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol FullscreenCourseListInteractorProtocol {
    func doSomeAction(request: FullscreenCourseList.Something.Request)
}

final class FullscreenCourseListInteractor: FullscreenCourseListInteractorProtocol {
    let presenter: FullscreenCourseListPresenterProtocol
    let provider: FullscreenCourseListProviderProtocol

    init(
        presenter: FullscreenCourseListPresenterProtocol,
        provider: FullscreenCourseListProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    // MARK: Do some action

    func doSomeAction(request: FullscreenCourseList.Something.Request) {
        self.provider.fetchSomeItems().done { items in
            self.presenter.presentSomething(
                response: FullscreenCourseList.Something.Response(result: .success(items))
            )
        }.catch { _ in
            self.presenter.presentSomething(
                response: FullscreenCourseList.Something.Response(result: .failure(Error.fetchFailed))
            )
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
