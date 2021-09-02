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

    init(
        courseID: Course.IdType,
        searchResultsRepository: SearchResultsRepositoryProtocol,
        searchQueryResultsPersistenceService: SearchQueryResultsPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol
    ) {
        self.courseID = courseID
        self.searchResultsRepository = searchResultsRepository
        self.searchQueryResultsPersistenceService = searchQueryResultsPersistenceService
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
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
        self.searchResultsRepository.searchInCourse(self.courseID, query: query, page: page, dataSourceType: .remote)
    }

    func searchInCourseCache(query: String) -> Promise<[SearchResultPlainObject]> {
        self.searchResultsRepository
            .searchInCourse(self.courseID, query: query, page: 1, dataSourceType: .cache)
            .map { $0.0 }
    }
}
