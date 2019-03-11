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
    private let userCoursesAPI: UserCoursesAPI

    init(
        type: EnrolledCourseListType,
        coursesAPI: CoursesAPI,
        userCoursesAPI: UserCoursesAPI
    ) {
        self.type = type
        self.userCoursesAPI = userCoursesAPI
        super.init(coursesAPI: coursesAPI)
    }

    func fetch(page: Int = 1) -> Promise<([Course], Meta)> {
        return Promise { seal in
            self.userCoursesAPI.retrieve(page: page).then {
                userCoursesInfo -> Promise<([Course], [UserCourse], Meta)> in
                // Cause we can't pass empty ids list to courses endpoint
                if userCoursesInfo.0.isEmpty {
                    return Promise.value(([], [], Meta.oneAndOnlyPage))
                }

                return self.coursesAPI.retrieve(
                    ids: userCoursesInfo.0.map { $0.courseId }
                ).map { ($0, userCoursesInfo.0, userCoursesInfo.1) }
            }.done { courses, info, meta in
                let orderedCourses = courses.reordered(
                    order: info.map { $0.courseId },
                    transform: { $0.id }
                )
                seal.fulfill((orderedCourses, meta))
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
                isPopular: true,
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
                let courses = courses.reordered(order: self.type.ids, transform: { $0.id })
                seal.fulfill((courses, finalMeta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }
}

final class SearchResultCourseListNetworkService: BaseCourseListNetworkService,
                                                  CourseListNetworkServiceProtocol {
    let type: SearchResultCourseListType
    private let searchResultsAPI: SearchResultsAPI

    init(
        type: SearchResultCourseListType,
        coursesAPI: CoursesAPI,
        searchResultsAPI: SearchResultsAPI
    ) {
        self.type = type
        self.searchResultsAPI = searchResultsAPI
        super.init(coursesAPI: coursesAPI)
    }

    func fetch(page: Int) -> Promise<([Course], Meta)> {
        return Promise { seal in
            self.searchResultsAPI.searchCourse(
                query: self.type.query,
                language: self.type.language,
                page: page
            ).then { result, meta -> Promise<([Int], Meta, [Course])> in
                let ids = result.compactMap { $0.courseId }
                return self.coursesAPI.retrieve(
                    ids: ids
                ).map { (ids, meta, $0) }
            }.done { ids, meta, courses in
                let resultCourses = courses.reordered(order: ids, transform: { $0.id })
                seal.fulfill((resultCourses, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }
}
