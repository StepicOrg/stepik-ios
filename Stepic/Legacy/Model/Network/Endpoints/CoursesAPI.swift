//
//  CoursesAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CoursesAPI: APIEndpoint {
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol

    override class var name: String { "courses" }

    init(
        coursesPersistenceService: CoursesPersistenceServiceProtocol = CoursesPersistenceService(),
        timeoutIntervalForRequest: TimeInterval = APIDefaults.Configuration.increasedTimeoutIntervalForRequest
    ) {
        self.coursesPersistenceService = coursesPersistenceService
        super.init(timeoutIntervalForRequest: timeoutIntervalForRequest)
    }

    @discardableResult
    func retrieve(
        ids: [Int],
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        existing: [Course]
    ) -> Promise<[Course]> {
        if ids.isEmpty {
            return .value([])
        }

        if RemoteConfig.shared.coursesApiFilterFreeOnly {
            return self.getObjectsByIds(ids: ids, updating: existing).filterValues({ !$0.isPaid })
        } else {
            return self.getObjectsByIds(ids: ids, updating: existing)
        }
    }

    @available(*, deprecated, message: "Legacy: we want to pass existing")
    @discardableResult
    func retrieve(
        ids: [Int],
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders
    ) -> Promise<[Course]> {
        if ids.isEmpty {
            return .value([])
        }

        if RemoteConfig.shared.coursesApiFilterFreeOnly {
            return self.coursesPersistenceService
                .fetch(ids: ids)
                .then { cachedCourses, _ in
                    self.getObjectsByIds(ids: ids, updating: cachedCourses)
                }
                .then { self.indexCoursesInSpotlight($0) }
                .filterValues({ !$0.isPaid })
        } else {
            return self.coursesPersistenceService
                .fetch(ids: ids)
                .then { cachedCourses, _ in
                    self.getObjectsByIds(ids: ids, updating: cachedCourses)
                }
                .then { self.indexCoursesInSpotlight($0) }
        }
    }

    func retrieve(
        tag: Int? = nil,
        teacher: Int? = nil,
        featured: Bool? = nil,
        enrolled: Bool? = nil,
        excludeEnded: Bool? = nil,
        isPublic: Bool? = nil,
        isPopular: Bool? = nil,
        isCataloged: Bool? = nil,
        order: Order? = nil,
        language: String? = nil,
        page: Int = 1,
        courseListFilterQuery: CourseListFilterQuery? = nil
    ) -> Promise<([Course], Meta)> {
        var params = Parameters()

        if let isFeatured = featured {
            params["is_featured"] = String(describing: isFeatured)
        }

        if let isEnrolled = enrolled {
            params["enrolled"] = String(describing: isEnrolled)
        }

        if let excludeEnded = excludeEnded {
            params["exclude_ended"] = String(describing: excludeEnded)
        }

        if let isPublic = isPublic {
            params["is_public"] = String(describing: isPublic)
        }

        if let isPopular = isPopular {
            params["is_popular"] = String(describing: isPopular)
        }

        if let isCataloged = isCataloged {
            params["is_cataloged"] = String(describing: isCataloged)
        }

        if let order = order {
            params["order"] = order.rawValue
        }

        if let language = language {
            params["language"] = language
        }

        if let tag = tag {
            params["tag"] = tag
        }

        if let teacher = teacher {
            params["teacher"] = teacher
        }

        if let courseListFilterQuery = courseListFilterQuery {
            courseListFilterQuery.dictValue.forEach { key, value in
                params[key] = String(describing: value)
            }

            if courseListFilterQuery.language == nil {
                params["language"] = nil
            }
        }

        params["page"] = page

        if RemoteConfig.shared.coursesApiFilterFreeOnly {
            return self.retrieve
                .requestWithFetching(
                    requestEndpoint: "courses",
                    paramName: "courses",
                    params: params,
                    withManager: self.manager
                )
                .then { courses, meta in
                    self.indexCoursesInSpotlight(courses)
                        .map { _ in
                            (courses.filter({ !$0.isPaid }), meta)
                        }
                }
        } else {
            return self.retrieve
                .requestWithFetching(
                    requestEndpoint: "courses",
                    paramName: "courses",
                    params: params,
                    withManager: self.manager
                )
                .then { courses, meta in
                    self.indexCoursesInSpotlight(courses)
                        .map { _ in
                            (courses, meta)
                        }
                }
        }
    }

    //Can't add this to extension because it is mocked in tests. "Declaration from extension cannot be overriden"
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult
    func retrieve(
        ids: [Int],
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        existing: [Course],
        refreshMode: RefreshMode,
        success: @escaping ([Course]) -> Void,
        error errorHandler: @escaping (NetworkError) -> Void
    ) -> Request? {
        self.getObjectsByIds(
            requestString: Self.name,
            printOutput: false,
            ids: ids,
            deleteObjects: existing,
            refreshMode: refreshMode,
            success: success,
            failure: errorHandler
        )
    }

    // TODO: Create CoursesRepository and index courses in spotlight on remote data source fetched result.
    private func indexCoursesInSpotlight(_ courses: [Course]) -> Promise<[Course]> {
        SpotlightIndexingService.shared.indexCourses(courses)
        return .value(courses)
    }

    enum Order: String {
        case activityDesc = "-activity"
        case popularityDesc = "-popularity"
    }
}

extension CoursesAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult
    func retrieve(
        tag: Int? = nil,
        featured: Bool? = nil,
        enrolled: Bool? = nil,
        excludeEnded: Bool? = nil,
        isPublic: Bool? = nil,
        order: Order? = nil,
        language: String? = nil,
        page: Int = 1,
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        success successHandler: @escaping ([Course], Meta) -> Void,
        error errorHandler: @escaping (Error) -> Void
    ) -> Request? {
        self.retrieve(
            tag: tag,
            featured: featured,
            enrolled: enrolled,
            excludeEnded: excludeEnded,
            isPublic: isPublic,
            order: order,
            language: language,
            page: page
        ).done { courses, meta in
            successHandler(courses, meta)
        }.catch { error in
            errorHandler(error)
        }
        return nil
    }
}
