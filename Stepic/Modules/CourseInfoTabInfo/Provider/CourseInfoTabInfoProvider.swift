//
//  CourseInfoTabInfoProvider.swift
//  stepik-ios
//
//  Created by Ivan Magda on 15/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseInfoTabInfoProviderProtocol {
    func fetchUsers(ids: [Int], existing: [User]) -> Promise<[User]>
}

final class CourseInfoTabInfoProvider: CourseInfoTabInfoProviderProtocol {
    private let usersAPI: UsersAPI

    init(usersAPI: UsersAPI) {
        self.usersAPI = usersAPI
    }

    func fetchUsers(ids: [Int], existing: [User]) -> Promise<[User]> {
        return Promise { seal in
            self.usersAPI.retrieve(
                ids: ids,
                existing: existing,
                refreshMode: .update,
                success: { users in
                    seal.fulfill(users)
                },
                error: { error in
                    seal.reject(error)
                }
            )
        }
    }
}
