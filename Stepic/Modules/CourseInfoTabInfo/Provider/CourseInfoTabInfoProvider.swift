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
    func fetchCourseUsers(_ course: Course) -> Promise<Course>
}

final class CourseInfoTabInfoProvider: CourseInfoTabInfoProviderProtocol {
    private let usersAPI: UsersAPI

    init(usersAPI: UsersAPI) {
        self.usersAPI = usersAPI
    }

    func fetchCourseUsers(_ course: Course) -> Promise<Course> {
        let ids = Array(Set(course.instructorsArray + course.authorsArray))
        let existingUsers = Array(Set(course.instructors + course.authors))

        return self.fetchUsers(ids: ids, existing: existingUsers).then { users -> Promise<Course> in
            let instructors = users.filter {
                course.instructorsArray.contains($0.id)
            }
            let authors = users.filter {
                course.authorsArray.contains($0.id)
            }

            course.instructors = Sorter.sort(instructors, byIds: course.instructorsArray)
            course.authors = Sorter.sort(authors, byIds: course.authorsArray)

            return .value(course)
        }
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
