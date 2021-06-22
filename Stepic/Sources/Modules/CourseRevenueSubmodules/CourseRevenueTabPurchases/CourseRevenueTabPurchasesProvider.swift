import Foundation
import PromiseKit

protocol CourseRevenueTabPurchasesProviderProtocol {
    func fetchCourseBenefits(courseID: Course.IdType, page: Int) -> Promise<FetchResult<([CourseBenefit], Meta)>>
    func fetchRemoteCourseBenefits(courseID: Course.IdType, page: Int) -> Promise<([CourseBenefit], Meta)>
}

extension CourseRevenueTabPurchasesProviderProtocol {
    func fetchCourseBenefits(courseID: Course.IdType) -> Promise<FetchResult<([CourseBenefit], Meta)>> {
        self.fetchCourseBenefits(courseID: courseID, page: 1)
    }
}

final class CourseRevenueTabPurchasesProvider: CourseRevenueTabPurchasesProviderProtocol {
    private let courseBenefitsPersistenceService: CourseBenefitsPersistenceServiceProtocol
    private let courseBenefitsNetworkService: CourseBenefitsNetworkServiceProtocol

    init(
        courseBenefitsPersistenceService: CourseBenefitsPersistenceServiceProtocol,
        courseBenefitsNetworkService: CourseBenefitsNetworkServiceProtocol
    ) {
        self.courseBenefitsPersistenceService = courseBenefitsPersistenceService
        self.courseBenefitsNetworkService = courseBenefitsNetworkService
    }

    func fetchCourseBenefits(courseID: Course.IdType, page: Int) -> Promise<FetchResult<([CourseBenefit], Meta)>> {
        Promise { seal in
            when(
                fulfilled: self.courseBenefitsPersistenceService.fetch(courseID: courseID),
                Guarantee(self.courseBenefitsNetworkService.fetch(courseID: courseID, page: page), fallback: nil)
            ).then { cachedCourseBenefits, remoteFetchResult -> Promise<FetchResult<([CourseBenefit], Meta)>> in
                if let remoteFetchResult = remoteFetchResult {
                    return .value(.init(value: remoteFetchResult, source: .remote))
                }
                return .value(.init(value: (cachedCourseBenefits, Meta.oneAndOnlyPage), source: .cache))
            }.done { fetchResult in
                seal.fulfill(fetchResult)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchRemoteCourseBenefits(courseID: Course.IdType, page: Int) -> Promise<([CourseBenefit], Meta)> {
        Promise { seal in
            self.courseBenefitsNetworkService.fetch(courseID: courseID, page: page).done {
                seal.fulfill($0)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
