//
//  CoursesNetworkService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 04.12.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol CoursesNetworkServiceProtocol: class {
    func fetch(ids: [Course.IdType]) -> Promise<[Course]>
    func fetch(id: Course.IdType) -> Promise<Course?>
}

final class CoursesNetworkService: CoursesNetworkServiceProtocol {
    private let coursesAPI: CoursesAPI

    init(coursesAPI: CoursesAPI) {
        self.coursesAPI = coursesAPI
    }

    func fetch(ids: [Course.IdType]) -> Promise<[Course]> {
        return Promise { seal in
            self.coursesAPI.retrieve(ids: ids).done { courses in
                let courses = courses.reordered(order: ids, transform: { $0.id })
                seal.fulfill(courses)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: Course.IdType) -> Promise<Course?> {
        return Promise { seal in
            self.fetch(ids: [id]).done { courses in
                seal.fulfill(courses.first)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
