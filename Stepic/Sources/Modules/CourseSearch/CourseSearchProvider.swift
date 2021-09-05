import Foundation
import PromiseKit

protocol CourseSearchProviderProtocol {
    func fetchCourse() -> Promise<Course?>
    func fetchSuggestions(fetchLimit: Int) -> Guarantee<[SearchQueryResult]>

    func searchInCourseRemotely(query: String, page: Int) -> Promise<([SearchResultPlainObject], Meta)>
    func searchInCourseCache(query: String) -> Promise<[SearchResultPlainObject]>
}

final class CourseSearchProvider: CourseSearchProviderProtocol {
    private let courseID: Course.IdType

    private let searchResultsRepository: SearchResultsRepositoryProtocol
    private let searchQueryResultsPersistenceService: SearchQueryResultsPersistenceServiceProtocol

    private let coursesNetworkService: CoursesNetworkServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol

    private let usersNetworkService: UsersNetworkServiceProtocol
    private let usersPersistenceService: UsersPersistenceServiceProtocol

    init(
        courseID: Course.IdType,
        searchResultsRepository: SearchResultsRepositoryProtocol,
        searchQueryResultsPersistenceService: SearchQueryResultsPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        usersNetworkService: UsersNetworkServiceProtocol,
        usersPersistenceService: UsersPersistenceServiceProtocol
    ) {
        self.courseID = courseID
        self.searchResultsRepository = searchResultsRepository
        self.searchQueryResultsPersistenceService = searchQueryResultsPersistenceService
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.usersNetworkService = usersNetworkService
        self.usersPersistenceService = usersPersistenceService
    }

    func fetchCourse() -> Promise<Course?> {
        self.coursesPersistenceService.fetch(id: self.courseID).then { cachedCourse -> Promise<Course?> in
            if let cachedCourse = cachedCourse {
                return .value(cachedCourse)
            }
            return self.coursesNetworkService.fetch(id: self.courseID)
        }
    }

    func fetchSuggestions(fetchLimit: Int) -> Guarantee<[SearchQueryResult]> {
        self.searchQueryResultsPersistenceService.fetch(courseID: self.courseID, fetchLimit: fetchLimit)
    }

    func searchInCourseRemotely(query: String, page: Int) -> Promise<([SearchResultPlainObject], Meta)> {
        var resultOrder = [Int]()
        var resultIDs = Set<Int>()
        var resultMeta = Meta.oneAndOnlyPage

        return Promise { seal in
            self.searchResultsRepository.searchInCourse(
                self.courseID,
                query: query,
                page: page,
                dataSourceType: .remote
            ).then { searchResults, meta -> Promise<SearchQueryResult> in
                resultOrder = searchResults.map(\.id)
                resultIDs = Set(resultOrder)
                resultMeta = meta

                return self.searchQueryResultsPersistenceService
                    .fetch(query: query, courseID: self.courseID)
                    .compactMap { $0 }
            }.then { searchQueryResult -> Guarantee<SearchQueryResult> in
                self.fetchAndMergeUsers(searchQueryResult)
            }.done { searchQueryResult in
                let searchResults = searchQueryResult
                    .searchResults
                    .filter { resultIDs.contains($0.id) }
                    .reordered(order: resultOrder, transform: { $0.id })
                    .map(\.plainObject)
                seal.fulfill((searchResults, resultMeta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func searchInCourseCache(query: String) -> Promise<[SearchResultPlainObject]> {
        self.searchResultsRepository
            .searchInCourse(self.courseID, query: query, page: 1, dataSourceType: .cache)
            .map { $0.0 }
    }

    // MARK: Private API

    private func fetchAndMergeUsers(_ searchQueryResult: SearchQueryResult) -> Guarantee<SearchQueryResult> {
        let usersIDs = Set(searchQueryResult.searchResults.compactMap(\.commentUserID))

        if usersIDs.isEmpty {
            return .value(searchQueryResult)
        }

        return Guarantee { seal in
            self.fetchUsers(Array(usersIDs)).done { users in
                if users.isEmpty {
                    return seal(searchQueryResult)
                }

                let usersMap = Dictionary(uniqueKeysWithValues: users.map({ ($0.id, $0) }))

                searchQueryResult.managedObjectContext?.performChanges {
                    for searchResult in searchQueryResult.searchResults {
                        if let commentUserID = searchResult.commentUserID {
                            searchResult.commentUser = usersMap[commentUserID]
                        }
                    }

                    seal(searchQueryResult)
                }
            }
        }
    }

    private func fetchUsers(_ ids: [User.IdType]) -> Guarantee<[User]> {
        self.usersPersistenceService.fetch(ids: ids).then { cachedUsers -> Guarantee<[User]> in
            let targetIDs = Set(ids)
            let cachedIDs = Set(cachedUsers.map(\.id))
            let cacheMissIDs = targetIDs.subtracting(cachedIDs)

            if cacheMissIDs.isEmpty {
                return .value(cachedUsers)
            } else {
                return Guarantee(
                    self.usersNetworkService.fetch(ids: Array(cacheMissIDs)),
                    fallback: nil
                ).map { cachedUsers + ($0 ?? []) }
            }
        }
    }
}
