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

final class CourseListNetworkService: CourseListNetworkServiceProtocol {
    let type: CourseListType

    private let coursesAPI: CoursesAPI

    init(
        type: CourseListType,
        coursesAPI: CoursesAPI
    ) {
        self.type = type
        self.coursesAPI = coursesAPI
    }

    func fetch(page: Int = 1) -> Promise<([Course], Meta)> {
        if let type = self.type as? EnrolledCourseListType {
            return self.fetchEnrolled(type)
        } else if let type = self.type as? PopularCourseListType {
            return self.fetchPopular(type)
        } else if let type = self.type as? TagCourseListType {
            return self.fetchTag(type)
        } else if let type = self.type as? CollectionCourseListType {
            return self.fetchCollection(type)
        } else {
            fatalError("Unsupported course list type")
        }
    }

    // MARK: - Private fetching methods

    private func fetchEnrolled(
        _ type: EnrolledCourseListType,
        page: Int = 1
    ) -> Promise<([Course], Meta)> {
        return Promise { seal in
            coursesAPI.retrieve(
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

    private func fetchPopular(
        _ type: PopularCourseListType,
        page: Int = 1
    ) -> Promise<([Course], Meta)> {
        return Promise { seal in
            coursesAPI.retrieve(
                excludeEnded: true,
                isPublic: true,
                order: "-activity",
                language: type.language,
                page: page
            ).done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    private func fetchTag(
        _ type: TagCourseListType,
        page: Int = 1
    ) -> Promise<([Course], Meta)> {
        return Promise { seal in
            coursesAPI.retrieve(
                tag: type.id,
                order: "-activity",
                language: type.language,
                page: page
            ).done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    private func fetchCollection(
        _ type: CollectionCourseListType,
        page: Int = 1
    ) -> Promise<([Course], Meta)> {
        let finalMeta = Meta.oneAndOnlyPage
        return Promise { seal in
            coursesAPI.retrieve(
                ids: type.ids
            ).done { courses in
                seal.fulfill((courses, finalMeta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
