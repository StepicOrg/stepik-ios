//
//  SearchResultsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class SearchResultsAPI: APIEndpoint {
    override var name: String { return "search-results" }

    @available(*, deprecated, message: "Use searchCourse() -> Promise<([SearchResult], Meta)> instead")
    @discardableResult func search(query: String, type: String?, language: ContentLanguage? = nil, page: Int?, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([SearchResult], Meta) -> Void, error errorHandler: @escaping (NSError) -> Void) -> Request? {
        var params: Parameters = [:]

        params["access_token"] = AuthInfo.shared.token?.accessToken as NSObject?
        params["query"] = query.lowercased()

        if let p = page {
            params["page"] = p
        }
        if let t = type {
            params["type"] = t
        }
        if let l = language {
            params["language"] = l.languageString
        }

        return manager.request("\(StepicApplicationsInfo.apiURL)/search-results", method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
            response in

            var error = response.result.error
            var json: JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
//            let response = response.response

            if let e = error as NSError? {
                errorHandler(e)
                return
            }

            let meta = Meta(json: json["meta"])
            var results = [SearchResult]()
            for resultJson in json["search-results"].arrayValue {
                results += [SearchResult(json: resultJson)]
            }

            success(results, meta)
        })
    }

    func searchCourse(query: String, language: ContentLanguage?, page: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<([SearchResult], Meta)> {
        return Promise<([SearchResult], Meta)> { seal in
            search(query: query, type: "course", language: language, page: page, headers: headers, success: {
                searchResults, meta in
                seal.fulfill((searchResults, meta))
            }, error: {
                error in
                seal.reject(NetworkError(error: error))
            })
        }
    }
}
