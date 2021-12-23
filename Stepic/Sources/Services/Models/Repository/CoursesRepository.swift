import Foundation
import PromiseKit

protocol CoursesRepositoryProtocol: AnyObject {
    func fetch(id: Course.IdType, dataSourceType: DataSourceType) -> Promise<Course?>
}

extension CoursesRepositoryProtocol {
    func fetch(id: Course.IdType, fetchPolicy: DataFetchPolicy) -> Promise<Course?> {
        switch fetchPolicy {
        case .cacheFirst:
            return Guarantee(
                self.fetch(id: id, dataSourceType: .cache),
                fallback: nil
            ).then { cachedCourseOrNil -> Promise<Course?> in
                if let cachedCourse = cachedCourseOrNil?.flatMap({ $0 }) {
                    return .value(cachedCourse)
                } else {
                    return self.fetch(id: id, dataSourceType: .remote)
                }
            }
        case .remoteFirst:
            return Guarantee(
                self.fetch(id: id, dataSourceType: .remote),
                fallback: nil
            ).then { remoteCourseOrNil -> Promise<Course?> in
                if let remoteCourse = remoteCourseOrNil?.flatMap({ $0 }) {
                    return .value(remoteCourse)
                } else {
                    return self.fetch(id: id, dataSourceType: .cache)
                }
            }
        }
    }
}

final class CoursesRepository: CoursesRepositoryProtocol {
    private let coursesNetworkService: CoursesNetworkServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol

    init(
        coursesNetworkService: CoursesNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol
    ) {
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
    }

    func fetch(id: Course.IdType, dataSourceType: DataSourceType) -> Promise<Course?> {
        switch dataSourceType {
        case .remote:
            return self.coursesNetworkService.fetch(id: id)
        case .cache:
            return self.coursesPersistenceService.fetch(id: id)
        }
    }
}

extension CoursesRepository {
    static var `default`: CoursesRepository {
        CoursesRepository(
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            coursesPersistenceService: CoursesPersistenceService()
        )
    }
}
