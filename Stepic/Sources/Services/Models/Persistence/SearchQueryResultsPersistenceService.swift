import Foundation
import PromiseKit

protocol SearchQueryResultsPersistenceServiceProtocol: AnyObject {
    func fetch(query: String, courseID: Course.IdType) -> Guarantee<SearchQueryResult?>
    func fetch(courseID: Course.IdType, fetchLimit: Int) -> Guarantee<[SearchQueryResult]>

    func save(
        query: String,
        courseID: Course.IdType,
        page: Int,
        searchResults: [SearchResultPlainObject]
    ) -> Guarantee<Void>

    func deleteAll() -> Promise<Void>
}

final class SearchQueryResultsPersistenceService: BasePersistenceService<SearchQueryResult>,
                                                  SearchQueryResultsPersistenceServiceProtocol {
    func fetch(query: String, courseID: Course.IdType) -> Guarantee<SearchQueryResult?> {
        .value(
            SearchQueryResult.findOrFetch(
                in: self.managedObjectContext,
                byID: SearchQueryResult.makeID(courseID: courseID, query: query)
            )
        )
    }

    func fetch(courseID: Course.IdType, fetchLimit: Int) -> Guarantee<[SearchQueryResult]> {
        Guarantee { seal in
            let request = SearchQueryResult.sortedFetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(SearchQueryResult.managedCourseId),
                NSNumber(value: courseID)
            )
            request.returnsObjectsAsFaults = false
            request.fetchLimit = fetchLimit

            do {
                let searchQueryResults = try self.managedObjectContext.fetch(request)
                seal(searchQueryResults)
            } catch {
                print("SearchQueryResultsPersistenceService :: \(#function) failed fetch with error = \(error)")
                seal([])
            }
        }
    }

    func save(
        query: String,
        courseID: Course.IdType,
        page: Int,
        searchResults: [SearchResultPlainObject]
    ) -> Guarantee<Void> {
        firstly {
            self.fetch(query: query, courseID: courseID)
        }.done { existedSearchQueryResultOrNil in
            if let existedSearchQueryResult = existedSearchQueryResultOrNil {
                self.managedObjectContext.performChanges {
                    let newSearchResultEntities = searchResults.map { searchResult in
                        SearchResult.insert(into: self.managedObjectContext, searchResult: searchResult)
                    }

                    if page == 1 {
                        existedSearchQueryResult.searchResults.forEach { self.managedObjectContext.delete($0) }
                        existedSearchQueryResult.searchResults = newSearchResultEntities
                    } else {
                        let newSearchResults = existedSearchQueryResult.searchResults + newSearchResultEntities
                        existedSearchQueryResult.searchResults = newSearchResults
                    }

                    existedSearchQueryResult.searchResults.forEach { $0.searchQueryResult = existedSearchQueryResult }
                    existedSearchQueryResult.lastSearchDate = Date()
                    existedSearchQueryResult.query = query
                }
            } else {
                self.managedObjectContext.performChanges {
                    _ = SearchQueryResult.insertSearchInCourseResults(
                        into: self.managedObjectContext,
                        courseID: courseID,
                        query: query,
                        searchResults: searchResults
                    )
                }
            }
        }
    }
}
