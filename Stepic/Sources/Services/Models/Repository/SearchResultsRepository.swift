import Foundation
import PromiseKit

protocol SearchResultsRepositoryProtocol: AnyObject {
    func searchInCourse(
        _ courseID: Course.IdType,
        query: String,
        page: Int,
        dataSourceType: DataSourceType
    ) -> Promise<([SearchResultPlainObject], Meta)>
}

extension SearchResultsRepositoryProtocol {
    func searchInCourse(
        _ course: Course,
        query: String,
        page: Int,
        dataSourceType: DataSourceType
    ) -> Promise<([SearchResultPlainObject], Meta)> {
        self.searchInCourse(course.id, query: query, page: page, dataSourceType: dataSourceType)
    }
}

final class SearchResultsRepository: SearchResultsRepositoryProtocol {
    private let searchResultsNetworkService: SearchResultsNetworkServiceProtocol
    private let searchQueryResultsPersistenceService: SearchQueryResultsPersistenceServiceProtocol

    init(
        searchResultsNetworkService: SearchResultsNetworkServiceProtocol,
        searchQueryResultsPersistenceService: SearchQueryResultsPersistenceServiceProtocol
    ) {
        self.searchResultsNetworkService = searchResultsNetworkService
        self.searchQueryResultsPersistenceService = searchQueryResultsPersistenceService
    }

    func searchInCourse(
        _ courseID: Course.IdType,
        query: String,
        page: Int,
        dataSourceType: DataSourceType
    ) -> Promise<([SearchResultPlainObject], Meta)> {
        switch dataSourceType {
        case .cache:
            return self.searchQueryResultsPersistenceService
                .fetch(query: query, courseID: courseID)
                .then { searchQueryResult -> Promise<([SearchResultPlainObject], Meta)> in
                    if let searchQueryResult = searchQueryResult {
                        let searchResults = searchQueryResult.searchResults.map(\.plainObject)
                        return .value((searchResults, .oneAndOnlyPage))
                    } else {
                        return .value(([], .oneAndOnlyPage))
                    }
                }
        case .remote:
            return self.searchResultsNetworkService
                .searchInCourse(courseID, query: query, page: page)
                .then { remoteSearchResults, meta in
                    self.searchQueryResultsPersistenceService
                        .save(query: query, courseID: courseID, page: page, searchResults: remoteSearchResults)
                        .map { (remoteSearchResults, meta) }
                }
        }
    }
}

extension SearchResultsRepository {
    static var `default`: SearchResultsRepository {
        SearchResultsRepository(
            searchResultsNetworkService: SearchResultsNetworkService(searchResultsAPI: SearchResultsAPI()),
            searchQueryResultsPersistenceService: SearchQueryResultsPersistenceService()
        )
    }
}
