import Foundation
import PromiseKit

protocol CourseListProviderProtocol: class {
    func fetchCached() -> Promise<([Course], Meta)>
    func fetchRemote(page: Int) -> Promise<([Course], Meta)>
}

final class CourseListProvider: CourseListProviderProtocol {
    let type: CourseListType

    private let persistenceService: CourseListPersistenceServiceProtocol?
    private let networkService: CourseListNetworkServiceProtocol
    private let progressesNetworkService: ProgressesNetworkServiceProtocol
    private let reviewSummariesNetworkService: CourseReviewSummariesNetworkServiceProtocol

    init(
        type: CourseListType,
        networkService: CourseListNetworkServiceProtocol,
        persistenceService: CourseListPersistenceServiceProtocol? = nil,
        progressesNetworkService: ProgressesNetworkServiceProtocol,
        reviewSummariesNetworkService: CourseReviewSummariesNetworkServiceProtocol
    ) {
        self.type = type
        self.persistenceService = persistenceService
        self.networkService = networkService
        self.progressesNetworkService = progressesNetworkService
        self.reviewSummariesNetworkService = reviewSummariesNetworkService
    }

    func fetchCached() -> Promise<([Course], Meta)> {
        guard let persistenceService = self.persistenceService else {
            return Promise.value(([], Meta.oneAndOnlyPage))
        }

        return Promise { seal in
            persistenceService.fetch().done { courses in
                seal.fulfill((courses, Meta.oneAndOnlyPage))
            }.catch { error in
                print("course list provider: unable to fetch courses from cache, error = \(error)")
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchRemote(page: Int) -> Promise<([Course], Meta)> {
        var meta = Meta.oneAndOnlyPage
        return Promise { seal in
            self.networkService.fetch(page: page).then {
                (courses, _) -> Promise<([Course], [Progress], [CourseReviewSummary])> in
                let progressIDs = courses.compactMap { $0.progressId }
                let summariesIDs = courses.compactMap { $0.reviewSummaryId }

                return when(
                    fulfilled: self.progressesNetworkService.fetch(ids: progressIDs, page: 1),
                    self.reviewSummariesNetworkService.fetch(ids: summariesIDs, page: 1)
                ).compactMap { (courses, $0.0, $1.0) }
            }.then { (courses, progresses, reviewSummaries) -> Guarantee<([Course])> in
                self.mergeAsync(
                    courses: courses,
                    progresses: progresses,
                    reviewSummaries: reviewSummaries
                )
            }.done { courses in
                self.persistenceService?.update(newCachedList: courses)

                seal.fulfill((courses, meta))
            }.catch { error in
                print("course list provider: unable to fetch courses from api, error = \(error)")
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    private func mergeAsync(
        courses: [Course],
        progresses: [Progress],
        reviewSummaries: [CourseReviewSummary]
    ) -> Guarantee<[Course]> {
        return Guarantee { seal in
            var progressesMap: [Progress.IdType: Progress] = progresses
                .reduce(into: [:]) { $0[$1.id] = $1 }
            var reviewSummariesMap: [CourseReviewSummary.IdType: CourseReviewSummary] = reviewSummaries
                .reduce(into: [:]) { $0[$1.id] = $1 }

            for i in 0..<courses.count {
                if let progressID = courses[i].progressId {
                    courses[i].progress = progressesMap[progressID]
                }
                if let reviewSummaryID = courses[i].reviewSummaryId {
                    courses[i].reviewSummary = reviewSummariesMap[reviewSummaryID]
                }
            }

            CoreDataHelper.instance.save()
            seal(courses)
        }
    }

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
    }
}
