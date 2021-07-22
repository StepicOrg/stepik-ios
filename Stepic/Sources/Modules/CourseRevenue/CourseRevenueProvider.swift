import Foundation
import PromiseKit

protocol CourseRevenueProviderProtocol {
    func fetchCourse() -> Promise<FetchResult<Course?>>
    func fetchCourseBenefitSummary() -> Promise<FetchResult<CourseBenefitSummary?>>
    func fetchCourseBeneficiary(userID: User.IdType) -> Promise<FetchResult<CourseBeneficiary?>>
    func fetchCourseWithAllData(userID: User.IdType) -> Promise<FetchResult<Course?>>
}

final class CourseRevenueProvider: CourseRevenueProviderProtocol {
    private let courseID: Course.IdType

    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let coursesNetworkService: CoursesNetworkServiceProtocol

    private let courseBenefitSummariesPersistenceService: CourseBenefitSummariesPersistenceServiceProtocol
    private let courseBenefitSummariesNetworkService: CourseBenefitSummariesNetworkServiceProtocol

    private let courseBeneficiariesPersistenceService: CourseBeneficiariesPersistenceServiceProtocol
    private let courseBeneficiariesNetworkService: CourseBeneficiariesNetworkServiceProtocol

    init(
        courseID: Course.IdType,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        courseBenefitSummariesPersistenceService: CourseBenefitSummariesPersistenceServiceProtocol,
        courseBenefitSummariesNetworkService: CourseBenefitSummariesNetworkServiceProtocol,
        courseBeneficiariesPersistenceService: CourseBeneficiariesPersistenceServiceProtocol,
        courseBeneficiariesNetworkService: CourseBeneficiariesNetworkServiceProtocol
    ) {
        self.courseID = courseID
        self.coursesPersistenceService = coursesPersistenceService
        self.coursesNetworkService = coursesNetworkService
        self.courseBenefitSummariesPersistenceService = courseBenefitSummariesPersistenceService
        self.courseBenefitSummariesNetworkService = courseBenefitSummariesNetworkService
        self.courseBeneficiariesPersistenceService = courseBeneficiariesPersistenceService
        self.courseBeneficiariesNetworkService = courseBeneficiariesNetworkService
    }

    func fetchCourse() -> Promise<FetchResult<Course?>> {
        Promise { seal in
            when(
                fulfilled: self.coursesPersistenceService.fetch(id: self.courseID),
                Guarantee(self.coursesNetworkService.fetch(id: self.courseID), fallback: nil)
            ).then { cachedCourse, remoteCourse -> Promise<FetchResult<Course?>> in
                if let remoteCourse = remoteCourse {
                    return .value(.init(value: remoteCourse, source: .remote))
                }
                return .value(.init(value: cachedCourse, source: .cache))
            }.done { fetchResult in
                seal.fulfill(fetchResult)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchCourseBenefitSummary() -> Promise<FetchResult<CourseBenefitSummary?>> {
        let persistenceGuarantee: Guarantee<CourseBenefitSummary?> =
            self.courseBenefitSummariesPersistenceService.fetch(id: self.courseID)
        let remoteGuarantee: Guarantee<CourseBenefitSummary??> = Guarantee(
            self.courseBenefitSummariesNetworkService.fetch(id: self.courseID),
            fallback: nil
        )

        return Promise { seal in
            when(
                fulfilled: persistenceGuarantee,
                remoteGuarantee
            ).then {
                cachedCourseBenefitSummary, remoteCourseBenefitSummary -> Promise<FetchResult<CourseBenefitSummary?>> in
                if let remoteCourseBenefitSummary = remoteCourseBenefitSummary {
                    return .value(.init(value: remoteCourseBenefitSummary, source: .remote))
                }
                return .value(.init(value: cachedCourseBenefitSummary, source: .cache))
            }.done { fetchResult in
                seal.fulfill(fetchResult)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchCourseBeneficiary(userID: User.IdType) -> Promise<FetchResult<CourseBeneficiary?>> {
        let persistenceGuarantee: Guarantee<CourseBeneficiary?>
            = self.courseBeneficiariesPersistenceService.fetch(courseID: self.courseID, userID: userID)
        let remoteGuarantee: Guarantee<CourseBeneficiary??> = Guarantee(
            self.courseBeneficiariesNetworkService.fetch(courseID: self.courseID, userID: userID),
            fallback: nil
        )

        return Promise { seal in
            when(
                fulfilled: persistenceGuarantee,
                remoteGuarantee
            ).then { cachedCourseBeneficiary, remoteCourseBeneficiary -> Promise<FetchResult<CourseBeneficiary?>> in
                if let remoteCourseBeneficiary = remoteCourseBeneficiary {
                    return .value(.init(value: remoteCourseBeneficiary, source: .remote))
                }
                return .value(.init(value: cachedCourseBeneficiary, source: .cache))
            }.done { fetchResult in
                seal.fulfill(fetchResult)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchCourseWithAllData(userID: User.IdType) -> Promise<FetchResult<Course?>> {
        Promise { seal in
            when(
                fulfilled: self.fetchCourse(),
                self.fetchCourseBenefitSummary(),
                self.fetchCourseBeneficiary(userID: userID)
            ).done { courseFetchResult, courseBenefitSummaryFetchResult, courseBeneficiaryFetchResult in
                if let courseBenefitSummary = courseBenefitSummaryFetchResult.value {
                    courseBenefitSummary.course = courseFetchResult.value
                    CoreDataHelper.shared.save()
                }
                if let courseBeneficiary = courseBeneficiaryFetchResult.value {
                    courseBeneficiary.course = courseFetchResult.value
                    CoreDataHelper.shared.save()
                }

                seal.fulfill(courseFetchResult)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
