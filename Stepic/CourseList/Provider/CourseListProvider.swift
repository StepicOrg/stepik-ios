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
    func fetch(shouldFetchOnlyCached: Bool, page: Int) -> Promise<([Course], Meta)>
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

    func fetch(shouldFetchOnlyCached: Bool, page: Int) -> Promise<([Course], Meta)> {
        // Check for state and if state == offline, just fetch cached courses
        // if state == online, fetch from network and update cached courses
        if shouldFetchOnlyCached {
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

        return Promise { seal in
            self.networkService.fetch(page: page).done { (courses, meta) in
                self.persistenceService?.update(newCachedList: courses)
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
