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
    override var name: String { "courses" }

    @discardableResult
    func retrieve(
        ids: [Int],
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        existing: [Course]
    ) -> Promise<[Course]> {
        if ids.isEmpty {
            return .value([])
        }

        return self.getObjectsByIds(ids: ids, updating: existing)
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

        return self.getObjectsByIds(
            ids: ids,
            updating: Course.getCourses(ids)
        ).then { self.indexCoursesInSpotlight($0) }
    }

    func retrieve(
        tag: Int? = nil,
        featured: Bool? = nil,
        enrolled: Bool? = nil,
        excludeEnded: Bool? = nil,
        isPublic: Bool? = nil,
        isPopular: Bool? = nil,
        order: String? = nil,
        language: String? = nil,
        page: Int = 1
    ) -> Promise<([Course], Meta)> {
        var params = Parameters()

        if let isFeatured = featured {
            params["is_featured"] = isFeatured ? "true" : "false"
        }

        if let isEnrolled = enrolled {
            params["enrolled"] = isEnrolled ? "true" : "false"
        }

        if let excludeEnded = excludeEnded {
            params["exclude_ended"] = excludeEnded ? "true" : "false"
        }

        if let isPublic = isPublic {
            params["is_public"] = isPublic ? "true" : "false"
        }

        if let isPopular = isPopular {
            params["is_popular"] = isPopular ? "true" : "false"
        }

        if let order = order {
            params["order"] = order
        }

        if let language = language {
            params["language"] = language
        }

        if let tag = tag {
            params["tag"] = tag
        }

        params["page"] = page

        return self.retrieve.requestWithFetching(
            requestEndpoint: "courses",
            paramName: "courses",
            params: params,
            withManager: self.manager
        ).then { courses, meta in
            self.indexCoursesInSpotlight(courses).map { _ in (courses, meta) }
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
        success: @escaping (([Course]) -> Void),
        error errorHandler: @escaping ((NetworkError) -> Void)
    ) -> Request? {
        self.getObjectsByIds(
            requestString: self.name,
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
        order: String? = nil,
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
