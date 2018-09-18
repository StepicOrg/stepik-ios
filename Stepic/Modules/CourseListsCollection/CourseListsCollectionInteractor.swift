//
//  CourseListsCollectionInteractor.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseListsCollectionInteractorProtocol: class {
    func fetchCourseLists(request: CourseListsCollection.ShowCourseLists.Request)
}

final class CourseListsCollectionInteractor: CourseListsCollectionInteractorProtocol {
    let presenter: CourseListsCollectionPresenterProtocol
    let provider: CourseListsCollectionProviderProtocol

    init(presenter: CourseListsCollectionPresenterProtocol, provider: CourseListsCollectionProviderProtocol) {
        self.presenter = presenter
        self.provider = provider
    }

    func fetchCourseLists(request: CourseListsCollection.ShowCourseLists.Request) {
        self.provider.fetchCachedCourseLists().then { cachedCourseLists -> Promise<[CourseListModel]> in
            // Pass cached data to presenter and start fetching from remote
            let response = Result<[CourseListModel]>.success(cachedCourseLists)
            self.presenter.presentCourses(
                response: CourseListsCollection.ShowCourseLists.Response(result: response)
            )

            return self.provider.fetchRemoteCourseLists()
        }.done { remoteCourseLists in
            let response = Result<[CourseListModel]>.success(remoteCourseLists)
            self.presenter.presentCourses(
                response: CourseListsCollection.ShowCourseLists.Response(result: response)
            )

            self.presenter.presentCourses(
                response: CourseListsCollection.ShowCourseLists.Response(result: response)
            )
        }.catch { _ in

        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
