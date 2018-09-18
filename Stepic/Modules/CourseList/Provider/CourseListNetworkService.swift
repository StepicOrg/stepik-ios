//
//  CourseListNetworkService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseListNetworkServiceProtocol: class {
    func fetch(page: Int) -> Promise<([Course], Meta)>
}

class BaseCourseListNetworkService {
    let coursesAPI: CoursesAPI

    init(coursesAPI: CoursesAPI) {
        self.coursesAPI = coursesAPI
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

final class EnrolledCourseListNetworkService: BaseCourseListNetworkService,
                                              CourseListNetworkServiceProtocol {
    let type: EnrolledCourseListType

    init(type: EnrolledCourseListType, coursesAPI: CoursesAPI) {
        self.type = type
        super.init(coursesAPI: coursesAPI)
    }

    func fetch(page: Int = 1) -> Promise<([Course], Meta)> {
        return Promise { seal in
            self.coursesAPI.retrieve(
                enrolled: true,
                order: "-activity",
                page: page
            ).done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }
}

final class PopularCourseListNetworkService: BaseCourseListNetworkService,
                                             CourseListNetworkServiceProtocol {
    let type: PopularCourseListType

    init(type: PopularCourseListType, coursesAPI: CoursesAPI) {
        self.type = type
        super.init(coursesAPI: coursesAPI)
    }

    func fetch(page: Int = 1) -> Promise<([Course], Meta)> {
        return Promise { seal in
            self.coursesAPI.retrieve(
                excludeEnded: true,
                isPublic: true,
                order: "-activity",
                language: self.type.language.popularCoursesParameter,
                page: page
            ).done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }
}

final class TagCourseListNetworkService: BaseCourseListNetworkService,
                                         CourseListNetworkServiceProtocol {
    let type: TagCourseListType

    init(type: TagCourseListType, coursesAPI: CoursesAPI) {
        self.type = type
        super.init(coursesAPI: coursesAPI)
    }

    func fetch(page: Int = 1) -> Promise<([Course], Meta)> {
        return Promise { seal in
            self.coursesAPI.retrieve(
                tag: self.type.id,
                order: "-activity",
                language: self.type.language.languageString,
                page: page
            ).done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }
}

final class CollectionCourseListNetworkService: BaseCourseListNetworkService,
                                                CourseListNetworkServiceProtocol {
    let type: CollectionCourseListType

    init(type: CollectionCourseListType, coursesAPI: CoursesAPI) {
        self.type = type
        super.init(coursesAPI: coursesAPI)
    }

    func fetch(page: Int = 1) -> Promise<([Course], Meta)> {
        let finalMeta = Meta.oneAndOnlyPage
        return Promise { seal in
            self.coursesAPI.retrieve(
                ids: self.type.ids
            ).done { courses in
                seal.fulfill((courses, finalMeta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }
}
