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
    func doSomeAction(request: ContinueCourse.Something.Request)
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
    
    // MARK: Do some action

    func doSomeAction(request: ContinueCourse.Something.Request) {
        self.provider.fetchSomeItems().done { items in
            self.presenter.presentSomething(
                response: ContinueCourse.Something.Response(result: .success(items))
            )
        }.catch { error in
            self.presenter.presentSomething(
                response: ContinueCourse.Something.Response(result: .failure(Error.fetchFailed))
            )
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}