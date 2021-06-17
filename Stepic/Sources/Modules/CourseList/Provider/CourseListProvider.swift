import Foundation
import PromiseKit

protocol CourseListProviderProtocol: AnyObject {
    func fetchCached() -> Promise<([Course], Meta)>
    func fetchRemote(page: Int, filterQuery: CourseListFilterQuery?) -> Promise<([Course], Meta)>
    func cache(courses: [Course])
    func fetchCachedCourseList() -> Guarantee<CourseListModel?>
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

    private let iapService: IAPServiceProtocol

    init(
        type: CourseListType,
        networkService: CourseListNetworkServiceProtocol,
        persistenceService: CourseListPersistenceServiceProtocol? = nil,
        progressesNetworkService: ProgressesNetworkServiceProtocol,
        reviewSummariesNetworkService: CourseReviewSummariesNetworkServiceProtocol,
        courseListsPersistenceService: CourseListsPersistenceServiceProtocol,
        iapService: IAPServiceProtocol
    ) {
        self.type = type
        self.persistenceService = persistenceService
        self.networkService = networkService
        self.progressesNetworkService = progressesNetworkService
        self.reviewSummariesNetworkService = reviewSummariesNetworkService
        self.courseListsPersistenceService = courseListsPersistenceService
        self.iapService = iapService
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
            ).then { (courses, meta) -> Promise<([Course], Meta, [Progress], [CourseReviewSummary], [String?])> in
                let progressesIDs = courses.compactMap { $0.progressId }
                let summariesIDs = courses.compactMap { $0.reviewSummaryId }

                let iapPricePromises = courses.map { course -> Promise<String?> in
                    self.iapService.canBuyCourse(course)
                        ? Promise(self.iapService.getLocalizedPrice(for: course))
                        : .value(nil)
                }

                return when(
                    fulfilled: self.progressesNetworkService.fetch(ids: progressesIDs, page: 1),
                    self.reviewSummariesNetworkService.fetch(ids: summariesIDs, page: 1),
                    when(fulfilled: iapPricePromises)
                ).compactMap { (courses, meta, $0.0, $1.0, $2) }
            }.then { (courses, meta, progresses, reviewSummaries, iapPrices) -> Guarantee<([Course], Meta)> in
                self.mergeAsync(
                    courses: courses,
                    progresses: progresses,
                    reviewSummaries: reviewSummaries,
                    iapPrices: iapPrices
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

    // MARK: - Private API

    private func mergeAsync(
        courses: [Course],
        progresses: [Progress],
        reviewSummaries: [CourseReviewSummary],
        iapPrices: [String?]
    ) -> Guarantee<[Course]> {
        Guarantee { seal in
            let progressesMap: [Progress.IdType: Progress] = progresses
                .reduce(into: [:]) { $0[$1.id] = $1 }
            let reviewSummariesMap: [CourseReviewSummary.IdType: CourseReviewSummary] = reviewSummaries
                .reduce(into: [:]) { $0[$1.id] = $1 }

            for i in 0..<courses.count {
                if let progressID = courses[i].progressId {
                    courses[i].progress = progressesMap[progressID]
                }
                if let reviewSummaryID = courses[i].reviewSummaryId {
                    courses[i].reviewSummary = reviewSummariesMap[reviewSummaryID]
                }
                courses[i].displayPriceIAP = iapPrices[i]
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
