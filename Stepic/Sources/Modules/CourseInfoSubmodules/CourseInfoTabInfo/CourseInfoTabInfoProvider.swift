import Foundation
import PromiseKit

protocol CourseInfoTabInfoProviderProtocol {
    var streamVideoQuality: StreamVideoQuality { get }

    func fetchUsersForCourse(_ course: Course) -> Promise<Course>
}

final class CourseInfoTabInfoProvider: CourseInfoTabInfoProviderProtocol {
    private let usersNetworkService: UsersNetworkServiceProtocol
    private let streamVideoQualityStorageManager: StreamVideoQualityStorageManagerProtocol

    var streamVideoQuality: StreamVideoQuality { self.streamVideoQualityStorageManager.streamVideoQuality }

    init(
        usersNetworkService: UsersNetworkServiceProtocol,
        streamVideoQualityStorageManager: StreamVideoQualityStorageManagerProtocol
    ) {
        self.usersNetworkService = usersNetworkService
        self.streamVideoQualityStorageManager = streamVideoQualityStorageManager
    }

    func fetchUsersForCourse(_ course: Course) -> Promise<Course> {
        let ids = Array(Set(course.instructorsArray + course.authorsArray))
        return Promise { seal in
            self.usersNetworkService.fetch(ids: ids).done { users in
                let instructors = users
                    .filter { course.instructorsArray.contains($0.id) }
                    .reordered(order: course.instructorsArray, transform: { $0.id })
                let authors = users
                    .filter { course.authorsArray.contains($0.id) }
                    .reordered(order: course.authorsArray, transform: { $0.id })
                course.instructors = instructors
                course.authors = authors

                seal.fulfill(course)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case networkFetchFailed
    }
}
