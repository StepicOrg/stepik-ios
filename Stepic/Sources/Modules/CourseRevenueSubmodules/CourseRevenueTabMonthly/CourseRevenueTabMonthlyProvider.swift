import Foundation
import PromiseKit

protocol CourseRevenueTabMonthlyProviderProtocol {
    func fetchCourseBenefitByMonths(
        courseID: Course.IdType,
        page: Int
    ) -> Promise<FetchResult<([CourseBenefitByMonth], Meta)>>
    func fetchRemoteCourseBenefitByMonths(courseID: Course.IdType, page: Int) -> Promise<([CourseBenefitByMonth], Meta)>
}

extension CourseRevenueTabMonthlyProviderProtocol {
    func fetchCourseBenefitByMonths(courseID: Course.IdType) -> Promise<FetchResult<([CourseBenefitByMonth], Meta)>> {
        self.fetchCourseBenefitByMonths(courseID: courseID, page: 1)
    }
}

final class CourseRevenueTabMonthlyProvider: CourseRevenueTabMonthlyProviderProtocol {
    private let courseBenefitByMonthsPersistenceService: CourseBenefitByMonthsPersistenceServiceProtocol
    private let courseBenefitByMonthsNetworkService: CourseBenefitByMonthsNetworkServiceProtocol

    init(
        courseBenefitByMonthsPersistenceService: CourseBenefitByMonthsPersistenceServiceProtocol,
        courseBenefitByMonthsNetworkService: CourseBenefitByMonthsNetworkServiceProtocol
    ) {
        self.courseBenefitByMonthsPersistenceService = courseBenefitByMonthsPersistenceService
        self.courseBenefitByMonthsNetworkService = courseBenefitByMonthsNetworkService
    }

    func fetchCourseBenefitByMonths(
        courseID: Course.IdType,
        page: Int
    ) -> Promise<FetchResult<([CourseBenefitByMonth], Meta)>> {
        Promise { seal in
            when(
                fulfilled: self.courseBenefitByMonthsPersistenceService.fetch(courseID: courseID),
                Guarantee(self.courseBenefitByMonthsNetworkService.fetch(courseID: courseID, page: page), fallback: nil)
            ).then { cachedFetchResult, remoteFetchResult -> Guarantee<FetchResult<([CourseBenefitByMonth], Meta)>> in
                if let remoteFetchResult = remoteFetchResult {
                    return .value(.init(value: remoteFetchResult, source: .remote))
                } else {
                    let sortedCourseBenefitByMonths = self.sortedCourseBenefitByMonths(cachedFetchResult)
                    return .value(.init(value: (sortedCourseBenefitByMonths, Meta.oneAndOnlyPage), source: .cache))
                }
            }.done { fetchResult in
                seal.fulfill(fetchResult)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchRemoteCourseBenefitByMonths(
        courseID: Course.IdType,
        page: Int
    ) -> Promise<([CourseBenefitByMonth], Meta)> {
        Promise { seal in
            self.courseBenefitByMonthsNetworkService.fetch(
                courseID: courseID,
                page: page
            ).done { fetchResult in
                seal.fulfill(fetchResult)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    private func sortedCourseBenefitByMonths(
        _ courseBenefitByMonths: [CourseBenefitByMonth]
    ) -> [CourseBenefitByMonth] {
        courseBenefitByMonths.sorted { lhs, rhs in
            guard let lhsDateInRegion = lhs.date,
                  let rhsDateInRegion = rhs.date else {
                return false
            }

            return lhsDateInRegion > rhsDateInRegion
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
