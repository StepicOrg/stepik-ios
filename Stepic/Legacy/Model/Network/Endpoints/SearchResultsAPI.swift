//
//  SearchResultsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class SearchResultsAPI: APIEndpoint {
    override var name: String { "search-results" }

    @available(*, deprecated, message: "Use searchCourse() -> Promise<([SearchResult], Meta)> instead")
    @discardableResult
    private func search(
        query: String,
        type: String?,
        language: ContentLanguage,
        page: Int?,
        filterQuery: CourseListFilterQuery? = nil,
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping ([SearchResult], Meta) -> Void,
        error errorHandler: @escaping (Error) -> Void
    ) -> Request? {
        var params: Parameters = [
            "query": query.lowercased(),
            "access_token": AuthInfo.shared.token?.accessToken ?? "",
            "language": language.searchCoursesParameter ?? "",
            "is_popular": "true",
            "is_public": "true",
            "readiness__gte": 0.7,
            "has_logo": "true",
            "is_idea_compatible": "false"
        ]

        if let page = page {
            params["page"] = page
        }
        if let type = type {
            params["type"] = type
        }

        if let filterQuery = filterQuery {
            filterQuery.dictValue.forEach { key, value in
                params[key] = String(describing: value)
            }

            if filterQuery.language == nil {
                params["language"] = nil
            }
        }

        return self.manager.request(
            "\(StepikApplicationsInfo.apiURL)/search-results",
            method: .get,
            parameters: params,
            encoding: URLEncoding.default,
            headers: headers
        ).responseSwiftyJSON { response in
            switch response.result {
            case .success(let json):
                let meta = Meta(json: json["meta"])
                let searchResults = json["search-results"]
                    .arrayValue
                    .map { SearchResult(json: $0) }
                success(searchResults, meta)
            case .failure(let error):
                errorHandler(error)
            }
        }
    }

    func searchCourse(
        query: String,
        language: ContentLanguage,
        page: Int,
        filterQuery: CourseListFilterQuery? = nil,
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders
    ) -> Promise<([SearchResult], Meta)> {
        Promise<([SearchResult], Meta)> { seal in
            self.search(
                query: query,
                type: "course",
                language: language,
                page: page,
                filterQuery: filterQuery,
                headers: headers,
                success: { searchResults, meta in
                    seal.fulfill((searchResults, meta))
                },
                error: { error in
                    seal.reject(NetworkError(error: error))
                }
            )
        }
    }
}
