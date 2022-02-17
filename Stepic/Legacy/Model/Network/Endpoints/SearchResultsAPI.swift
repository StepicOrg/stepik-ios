import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class SearchResultsAPI: APIEndpoint {
    override class var name: String { "search-results" }

    func searchCourses(
        query: String,
        language: ContentLanguage,
        page: Int,
        searchQueryParams: JSONDictionary = RemoteConfig.shared.searchResultsQueryParams,
        filterQuery: CourseListFilterQuery?
    ) -> Promise<([SearchResultPlainObject], Meta)> {
        self.search(
            query: query,
            type: .course,
            language: language,
            course: nil,
            page: page,
            searchQueryParams: searchQueryParams,
            filterQuery: filterQuery
        )
    }

    func searchInCourse(
        query: String,
        course: Int,
        page: Int
    ) -> Promise<([SearchResultPlainObject], Meta)> {
        self.search(
            query: query,
            type: nil,
            language: nil,
            course: course,
            page: page,
            searchQueryParams: nil,
            filterQuery: nil
        )
    }

    private func search(
        query: String,
        type: SearchResultTargetType?,
        language: ContentLanguage?,
        course: Int?,
        page: Int?,
        searchQueryParams: JSONDictionary?,
        filterQuery: CourseListFilterQuery?
    ) -> Promise<([SearchResultPlainObject], Meta)> {
        var params: JSONDictionary = [
            "query": query.lowercased()
        ]

        if let type = type {
            params["type"] = type
        }
        if let language = language {
            params["language"] = language.searchCoursesParameter ?? ""
        }
        if let course = course {
            params["course"] = course
        }
        if let page = page {
            params["page"] = page
        }

        if let searchQueryParams = searchQueryParams {
            params.merge(searchQueryParams) { (_, new) in new }
        }

        if let filterQuery = filterQuery {
            filterQuery.dictValue.forEach { key, value in
                params[key] = String(describing: value)
            }

            if filterQuery.language == nil {
                params["language"] = nil
            }
        }

        return self.retrieve.request(
            requestEndpoint: Self.name,
            params: params,
            withManager: self.manager
        ).map { json -> ([SearchResultPlainObject], Meta) in
            let searchResults = json[Self.name].arrayValue.map(SearchResultPlainObject.init(json:))
            let meta = Meta(json: json["meta"])
            return (searchResults, meta)
        }
    }
}
