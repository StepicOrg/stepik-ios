import Foundation
import PromiseKit

protocol SearchResultsRepositoryProtocol: AnyObject {
    func fetchByCourse(
        query: String,
        courseID: Course.IdType,
        page: Int,
        dataSourceType: DataSourceType
    ) -> Promise<([SearchResultPlainObject], Meta)>
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

    func fetchByCourse(
        query: String,
        courseID: Course.IdType,
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
                .fetchByCourse(query: query, courseID: courseID, page: page)
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
