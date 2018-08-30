//
//  CourseListProvider.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseListProviderProtocol: class {
    func fetchCached() -> Promise<([Course], Meta)>
    func fetchRemote(page: Int) -> Promise<([Course], Meta)>
}

final class CourseListProvider: CourseListProviderProtocol {
    let type: CourseListType

    private let persistenceService: CourseListPersistenceServiceProtocol?
    private let networkService: CourseListNetworkServiceProtocol

    init(
        type: CourseListType,
        networkService: CourseListNetworkServiceProtocol,
        persistenceService: CourseListPersistenceServiceProtocol? = nil
    ) {
        self.type = type
        self.persistenceService = persistenceService
        self.networkService = networkService
    }

    func fetchCached() -> Promise<([Course], Meta)> {
        guard let persistenceService = self.persistenceService else {
            return Promise.value(([], Meta.oneAndOnlyPage))
        }

        return Promise { seal in
            persistenceService.fetch().done { courses in
                seal.fulfill((courses, Meta.oneAndOnlyPage))
            }.catch { error in
                print("course list provider: unable to fetch courses from cache, " +
                    "error = \(error)")
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchRemote(page: Int) -> Promise<([Course], Meta)> {
        return Promise { seal in
            self.networkService.fetch(page: page).done { (courses, meta) in
                seal.fulfill((courses, meta))
            }.catch { error in
                print("course list provider: unable to fetch courses from api, " +
                    "error = \(error)")
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
    }
}
