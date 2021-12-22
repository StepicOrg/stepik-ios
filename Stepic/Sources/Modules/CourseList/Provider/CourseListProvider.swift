import Foundation
import PromiseKit

protocol CourseListProviderProtocol: AnyObject {
    func fetchCached() -> Promise<([Course], Meta)>
    func fetchRemote(page: Int, filterQuery: CourseListFilterQuery?) -> Promise<([Course], Meta)>

    func cache(courses: [Course])

    func fetchCachedCourseList() -> Guarantee<CourseListModel?>

    func fetchWishlist() -> Guarantee<[Course.IdType]>
}

extension CourseListProviderProtocol {
    func fetchRemote(page: Int) -> Promise<([Course], Meta)> {
        self.fetchRemote(page: page, filterQuery: nil)
    }
}

final class CourseListProvider: CourseListProviderProtocol {
    let type: CourseListType

    private let persistenceService: CourseListPersistenceServiceProtocol?
    private let networkService: CourseListNetworkServiceProtocol
    private let progressesNetworkService: ProgressesNetworkServiceProtocol
    private let reviewSummariesNetworkService: CourseReviewSummariesNetworkServiceProtocol
    private let courseListsPersistenceService: CourseListsPersistenceServiceProtocol
    private let wishlistEntriesPersistenceService: WishlistEntriesPersistenceServiceProtocol
    private let mobileTiersRepository: MobileTiersRepositoryProtocol

    private let iapService: IAPServiceProtocol

    private let remoteConfig: RemoteConfig

    init(
        type: CourseListType,
        networkService: CourseListNetworkServiceProtocol,
        persistenceService: CourseListPersistenceServiceProtocol? = nil,
        progressesNetworkService: ProgressesNetworkServiceProtocol,
        reviewSummariesNetworkService: CourseReviewSummariesNetworkServiceProtocol,
        courseListsPersistenceService: CourseListsPersistenceServiceProtocol,
        wishlistEntriesPersistenceService: WishlistEntriesPersistenceServiceProtocol,
        mobileTiersRepository: MobileTiersRepositoryProtocol,
        iapService: IAPServiceProtocol,
        remoteConfig: RemoteConfig
    ) {
        self.type = type
        self.persistenceService = persistenceService
        self.networkService = networkService
        self.progressesNetworkService = progressesNetworkService
        self.reviewSummariesNetworkService = reviewSummariesNetworkService
        self.courseListsPersistenceService = courseListsPersistenceService
        self.wishlistEntriesPersistenceService = wishlistEntriesPersistenceService
        self.mobileTiersRepository = mobileTiersRepository
        self.iapService = iapService
        self.remoteConfig = remoteConfig
    }

    // MARK: - CourseListProviderProtocol

    func fetchCached() -> Promise<([Course], Meta)> {
        guard let persistenceService = self.persistenceService else {
            return Promise.value(([], Meta.oneAndOnlyPage))
        }

        return Promise { seal in
            DispatchQueue.doWorkOnMain {
                persistenceService.fetch().done { courses in
                    seal.fulfill((courses, Meta.oneAndOnlyPage))
                }.catch { error in
                    print("course list provider: unable to fetch courses from cache, error = \(error)")
                    seal.reject(Error.persistenceFetchFailed)
                }
            }
        }
    }

    func fetchRemote(page: Int, filterQuery: CourseListFilterQuery?) -> Promise<([Course], Meta)> {
        Promise { seal in
            self.networkService.fetch(
                page: page,
                filterQuery: filterQuery
            ).then { (courses, meta) -> Promise<([Course], Meta, [Progress], [CourseReviewSummary])> in
                let progressesIDs = courses.compactMap { $0.progressID }
                let summariesIDs = courses.compactMap { $0.reviewSummaryID }

                return when(
                    fulfilled: self.progressesNetworkService.fetch(ids: progressesIDs, page: 1),
                    self.reviewSummariesNetworkService.fetch(ids: summariesIDs, page: 1),
                    self.fetchIAPLocalizedPrices(for: courses)
                ).compactMap { (courses, meta, $0.0.0, $0.1.0) }
            }.then { (courses, meta, progresses, reviewSummaries) -> Guarantee<([Course], Meta)> in
                self.mergeAsync(
                    courses: courses,
                    progresses: progresses,
                    reviewSummaries: reviewSummaries
                ).map { ($0, meta) }
            }.done { courses, meta in
                seal.fulfill((courses, meta))
            }.catch { error in
                print("course list provider: unable to fetch courses from api, error = \(error)")
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func cache(courses: [Course]) {
        self.persistenceService?.update(newCachedList: courses)
    }

    func fetchCachedCourseList() -> Guarantee<CourseListModel?> {
        guard let catalogBlockCourseList = self.type as? CatalogBlockCourseListType else {
            return .value(nil)
        }

        return self.courseListsPersistenceService.fetch(id: catalogBlockCourseList.courseListID)
    }

    func fetchWishlist() -> Guarantee<[Course.IdType]> {
        self.wishlistEntriesPersistenceService.fetchAll().mapValues(\.courseID)
    }

    // MARK: - Private API

    private func fetchIAPLocalizedPrices(for courses: [Course]) -> Guarantee<Void> {
        if courses.isEmpty {
            return .value(())
        }

        return firstly { () -> Guarantee<[MobileTierPlainObject]?> in
            switch self.remoteConfig.coursePurchaseFlow {
            case .web:
                return .value(nil)
            case .iap:
                return Guarantee(
                    self.mobileTiersRepository.fetch(
                        coursesIDsWithPromoCodesNames: courses.map { ($0.id, nil) },
                        dataSourceType: .remote
                    ),
                    fallback: nil
                )
            }
        }.then { mobileTiersOrNil -> Guarantee<Void> in
            let mobileTiers = mobileTiersOrNil ?? []
            let mobileTierByCourseID = Dictionary(
                mobileTiers.map({ ($0.courseID, $0) }),
                uniquingKeysWith: { first, _ in first }
            )

            return when(
                guarantees: courses.map {
                    self.fetchIAPLocalizedPrice(for: $0, mobileTiersMap: mobileTierByCourseID)
                }
            )
        }
    }

    private func fetchIAPLocalizedPrice(
        for course: Course,
        mobileTiersMap: [Course.IdType: MobileTierPlainObject]
    ) -> Guarantee<Void> {
        switch self.remoteConfig.coursePurchaseFlow {
        case .web:
            return Guarantee { seal in
                if self.iapService.canBuyCourse(course) {
                    self.iapService.fetchLocalizedPrice(for: course).done { price in
                        course.displayPriceIAP = price
                        seal(())
                    }
                } else {
                    course.displayPriceIAP = nil
                    seal(())
                }
            }
        case .iap:
            return Guarantee { seal in
                if let mobileTierPlainObject = mobileTiersMap[course.id],
                   let mobileTierEntity = course.mobileTiers.first(where: { $0.id == mobileTierPlainObject.id }) {
                    self.iapService.fetchLocalizedPrices(mobileTier: mobileTierEntity).done { result in
                        mobileTierEntity.priceTierDisplayPrice = result.priceTierLocalizedPrice
                        mobileTierEntity.promoTierDisplayPrice = result.promoTierLocalizedPrice

                        course.displayPriceTierPrice = result.priceTierLocalizedPrice
                        course.displayPriceTierPromo = result.promoTierLocalizedPrice

                        seal(())
                    }
                } else {
                    course.displayPriceTierPrice = nil
                    course.displayPriceTierPromo = nil

                    seal(())
                }
            }
        }
    }

    private func mergeAsync(
        courses: [Course],
        progresses: [Progress],
        reviewSummaries: [CourseReviewSummary]
    ) -> Guarantee<[Course]> {
        Guarantee { seal in
            let progressesMap: [Progress.IdType: Progress] = progresses
                .reduce(into: [:]) { $0[$1.id] = $1 }
            let reviewSummariesMap: [CourseReviewSummary.IdType: CourseReviewSummary] = reviewSummaries
                .reduce(into: [:]) { $0[$1.id] = $1 }

            for i in 0..<courses.count {
                if let progressID = courses[i].progressID {
                    courses[i].progress = progressesMap[progressID]
                }
                if let reviewSummaryID = courses[i].reviewSummaryID {
                    courses[i].reviewSummary = reviewSummariesMap[reviewSummaryID]
                }
            }

            CoreDataHelper.shared.save()
            seal(courses)
        }
    }

    // MARK: - Types

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
    }
}
