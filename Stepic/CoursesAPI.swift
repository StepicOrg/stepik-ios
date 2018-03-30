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

    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Course], refreshMode: RefreshMode, success: @escaping (([Course]) -> Void), error errorHandler: @escaping ((RetrieveError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, printOutput: false, ids: ids, deleteObjects: existing, refreshMode: refreshMode, success: success, failure: errorHandler)
    }

    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Course]) -> Promise<[Course]> {
        return getObjectsByIds(ids: ids, updating: existing)
    }

    @discardableResult func retrieve(tag: Int? = nil, featured: Bool? = nil, enrolled: Bool? = nil, excludeEnded: Bool? = nil, isPublic: Bool? = nil, order: String? = nil, language: ContentLanguage? = nil, page: Int = 1, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success successHandler: @escaping ([Course], Meta) -> Void, error errorHandler: @escaping (Error) -> Void) -> Request? {
        var params = Parameters()

        if let isFeatured = featured {
            params["is_featured"] = isFeatured ? "true" : "false"
        }

        if let isEnrolled = enrolled {
            params["enrolled"] = isEnrolled ? "true" : "false"
        }

        if let excludeEnded = excludeEnded {
            params["excludeEnded"] = excludeEnded ? "true" : "false"
        }

        if let isPublic = isPublic {
            params["is_public"] = isPublic ? "true" : "false"
        }

        if let order = order {
            params["order"] = order
        }

        if let language = language {
            params["language"] = language.languageString
        }

        if let tag = tag {
            params["tag"] = tag
        }

        params["page"] = page

        return manager.request("\(StepicApplicationsInfo.apiURL)/\(name)", parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseSwiftyJSON({ response in
            switch response.result {

            case .failure(let error):
                errorHandler(error)
                return
            case .success(let json):
                // get courses ids
                let jsonArray: [JSON] = json["courses"].array ?? []
                let ids: [Int] = jsonArray.flatMap { $0["id"].int }
                // recover course objects from database
                let recoveredCourses = Course.getCourses(ids)
                // update existing course objects or create new ones
                let resultCourses: [Course] = ids.enumerated().map {
                    idIndex, id in
                    let jsonObject = jsonArray[idIndex]
                    if let recoveredCourseIndex = recoveredCourses.index(where: {$0.id == id}) {
                        recoveredCourses[recoveredCourseIndex].update(json: jsonObject)
                        return recoveredCourses[recoveredCourseIndex]
                    } else {
                        return Course(json: jsonObject)
                    }
                }

                CoreDataHelper.instance.save()
                let meta = Meta(json: json["meta"])

                successHandler(resultCourses, meta)
                return
            }
        })
    }

    @discardableResult func retrieve(tag: Int? = nil, featured: Bool? = nil, enrolled: Bool? = nil, excludeEnded: Bool? = nil, isPublic: Bool? = nil, order: String? = nil, language: ContentLanguage? = nil, page: Int = 1, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<([Course], Meta)> {
        return Promise { fulfill, reject in
            retrieve(tag: tag, featured: featured, enrolled: enrolled, excludeEnded: excludeEnded, isPublic: isPublic, order: order, language: language, page: page, headers: headers, success: {
                courses, meta in
                fulfill((courses, meta))
            }, error: {
                error in
                reject(error)
            })
        }
    }

//    func retrieve(tag: Int? = nil, featured: Bool? = nil, enrolled: Bool? = nil, excludeEnded: Bool? = nil, isPublic: Bool? = nil, order: String? = nil, language: ContentLanguage? = nil, page: Int = 1, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<([Course], Meta)> {
//        retrieve.request
//    }
}
