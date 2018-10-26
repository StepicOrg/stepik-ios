//
//  CoursesAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class CoursesAPI: APIEndpoint {
    override var name: String { return "courses" }

    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Course]) -> Promise<[Course]> {
        return getObjectsByIds(ids: ids, updating: existing)
    }

    @available(*, deprecated, message: "Legacy: we want to pass existing")
    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<[Course]> {
        return getObjectsByIds(ids: ids, updating: Course.getCourses(ids))
    }

    func retrieve(tag: Int? = nil, featured: Bool? = nil, enrolled: Bool? = nil, excludeEnded: Bool? = nil, isPublic: Bool? = nil, isPopular: Bool? = nil, order: String? = nil, language: String? = nil, page: Int = 1) -> Promise<([Course], Meta)> {
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

        return retrieve.requestWithFetching(requestEndpoint: "courses", paramName: "courses", params: params, withManager: manager)
    }

    //Can't add this to extension because it is mocked in tests. "Declaration from extension cannot be overriden"
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Course], refreshMode: RefreshMode, success: @escaping (([Course]) -> Void), error errorHandler: @escaping ((NetworkError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, printOutput: false, ids: ids, deleteObjects: existing, refreshMode: refreshMode, success: success, failure: errorHandler)
    }
}

extension CoursesAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func retrieve(tag: Int? = nil, featured: Bool? = nil, enrolled: Bool? = nil, excludeEnded: Bool? = nil, isPublic: Bool? = nil, order: String? = nil, language: String? = nil, page: Int = 1, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success successHandler: @escaping ([Course], Meta) -> Void, error errorHandler: @escaping (Error) -> Void) -> Request? {
        retrieve(tag: tag, featured: featured, enrolled: enrolled, excludeEnded: excludeEnded, isPublic: isPublic, order: order, language: language, page: page).done { courses, meta in
            successHandler(courses, meta)
        }.catch {
            error in
            errorHandler(error)
        }
        return nil
    }

}
