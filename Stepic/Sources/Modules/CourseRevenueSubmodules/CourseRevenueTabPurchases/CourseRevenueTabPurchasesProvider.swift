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

    private let usersPersistenceService: UsersPersistenceServiceProtocol
    private let usersNetworkService: UsersNetworkServiceProtocol

    init(
        courseBenefitsPersistenceService: CourseBenefitsPersistenceServiceProtocol,
        courseBenefitsNetworkService: CourseBenefitsNetworkServiceProtocol,
        usersPersistenceService: UsersPersistenceServiceProtocol,
        usersNetworkService: UsersNetworkServiceProtocol
    ) {
        self.courseBenefitsPersistenceService = courseBenefitsPersistenceService
        self.courseBenefitsNetworkService = courseBenefitsNetworkService
        self.usersPersistenceService = usersPersistenceService
        self.usersNetworkService = usersNetworkService
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
            }.then { fetchResult -> Guarantee<FetchResult<([CourseBenefit], Meta)>> in
                self.fetchAndMergeBuyers(courseBenefits: fetchResult.value.0).map { fetchResult }
            }.done { fetchResult in
                seal.fulfill(fetchResult)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchRemoteCourseBenefits(courseID: Course.IdType, page: Int) -> Promise<([CourseBenefit], Meta)> {
        Promise { seal in
            self.courseBenefitsNetworkService.fetch(courseID: courseID, page: page).then { fetchResult in
                self.fetchAndMergeBuyers(courseBenefits: fetchResult.0).map { fetchResult }
            }.done {
                seal.fulfill($0)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    private func fetchAndMergeBuyers(courseBenefits: [CourseBenefit]) -> Guarantee<Void> {
        Guarantee(
            self.fetchUsersFromCacheOrNetwork(ids: courseBenefits.compactMap(\.buyerID)),
            fallback: nil
        ).done { buyersOrNil in
            if let buyers = buyersOrNil {
                courseBenefits.forEach { courseBenefit in
                    courseBenefit.buyer = buyers.first(where: { $0.id == courseBenefit.buyerID })
                }
                CoreDataHelper.shared.save()
            }
        }
    }

    private func fetchUsersFromCacheOrNetwork(ids: [User.IdType]) -> Promise<[User]> {
        if ids.isEmpty {
            return .value([])
        }

        return self.usersPersistenceService.fetch(ids: ids).then { cachedUsers -> Promise<[User]> in
            if Set(cachedUsers.map(\.id)) == Set(ids) {
                return .value(cachedUsers)
            }
            return self.usersNetworkService.fetch(ids: ids)
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
