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
    func fetchInstructors(course: Course) -> Promise<[User]>

    func fetchAuthors(course: Course) -> Promise<[User]>
}

final class CourseInfoTabInfoProvider: CourseInfoTabInfoProviderProtocol {
    private let usersAPI: UsersAPI

    init(usersAPI: UsersAPI) {
        self.usersAPI = usersAPI
    }

    func fetchInstructors(course: Course) -> Promise<[User]> {
        return self.fetchUsers(ids: course.instructorsArray, existing: course.instructors)
    }

    func fetchAuthors(course: Course) -> Promise<[User]> {
        return self.fetchUsers(ids: course.authorsArray, existing: course.authors)
    }

    private func fetchUsers(ids: [Int], existing: [User]) -> Promise<[User]> {
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
