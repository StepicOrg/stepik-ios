import Foundation
import PromiseKit

protocol SearchResultsNetworkServiceProtocol: AnyObject {
    func searchCourses(
        query: String,
        language: ContentLanguage,
        page: Int,
        searchQuery: JSONDictionary,
        filterQuery: CourseListFilterQuery?
    ) -> Promise<([SearchResultPlainObject], Meta)>
    func searchInCourse(
        _ courseID: Course.IdType,
        query: String,
        page: Int
    ) -> Promise<([SearchResultPlainObject], Meta)>
}

extension SearchResultsNetworkServiceProtocol {
    func searchCourses(
        query: String,
        language: ContentLanguage,
        page: Int = 1,
        searchQuery: JSONDictionary = RemoteConfig.shared.searchResultsQueryParams,
        filterQuery: CourseListFilterQuery? = nil
    ) -> Promise<([SearchResultPlainObject], Meta)> {
        self.searchCourses(
            query: query,
            language: language,
            page: page,
            searchQuery: searchQuery,
            filterQuery: filterQuery
        )
    }

    func searchInCourse(_ courseID: Course.IdType, query: String) -> Promise<([SearchResultPlainObject], Meta)> {
        self.searchInCourse(courseID, query: query, page: 1)
    }
}

final class SearchResultsNetworkService: SearchResultsNetworkServiceProtocol {
    private let searchResultsAPI: SearchResultsAPI

    init(searchResultsAPI: SearchResultsAPI) {
        self.searchResultsAPI = searchResultsAPI
    }

    func searchCourses(
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

    func searchInCourse(
        _ courseID: Course.IdType,
        query: String,
        page: Int
    ) -> Promise<([SearchResultPlainObject], Meta)> {
        self.searchResultsAPI.searchInCourse(query: query, course: courseID, page: page)
    }
}
