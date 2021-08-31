import Foundation
import PromiseKit

protocol SearchResultsNetworkServiceProtocol: AnyObject {
    func fetchCourses(
        query: String,
        language: ContentLanguage,
        page: Int,
        searchQuery: JSONDictionary,
        filterQuery: CourseListFilterQuery?
    ) -> Promise<([SearchResultPlainObject], Meta)>
    func fetchByCourse(query: String, courseID: Course.IdType, page: Int) -> Promise<([SearchResultPlainObject], Meta)>
}

extension SearchResultsNetworkServiceProtocol {
    func fetchCourses(
        query: String,
        language: ContentLanguage,
        page: Int = 1,
        searchQuery: JSONDictionary = RemoteConfig.shared.searchResultsQueryParams,
        filterQuery: CourseListFilterQuery? = nil
    ) -> Promise<([SearchResultPlainObject], Meta)> {
        self.fetchCourses(
            query: query,
            language: language,
            page: page,
            searchQuery: searchQuery,
            filterQuery: filterQuery
        )
    }

    func fetchByCourse(query: String, courseID: Course.IdType) -> Promise<([SearchResultPlainObject], Meta)> {
        self.fetchByCourse(query: query, courseID: courseID, page: 1)
    }
}

final class SearchResultsNetworkService: SearchResultsNetworkServiceProtocol {
    private let searchResultsAPI: SearchResultsAPI

    init(searchResultsAPI: SearchResultsAPI) {
        self.searchResultsAPI = searchResultsAPI
    }

    func fetchCourses(
        query: String,
        language: ContentLanguage,
        page: Int,
        searchQuery: JSONDictionary,
        filterQuery: CourseListFilterQuery?
    ) -> Promise<([SearchResultPlainObject], Meta)> {
        self.searchResultsAPI.searchCourses(
            query: query,
            language: language,
            page: page,
            searchQueryParams: searchQuery,
            filterQuery: filterQuery
        )
    }

    func fetchByCourse(
        query: String,
        courseID: Course.IdType,
        page: Int
    ) -> Promise<([SearchResultPlainObject], Meta)> {
        self.searchResultsAPI.searchByCourse(query: query, course: courseID, page: page)
    }
}
