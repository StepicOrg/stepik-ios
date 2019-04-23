import Foundation
import PromiseKit

protocol NewLessonProviderProtocol {
    func fetchLesson(id: Lesson.IdType) -> Promise<FetchResult<Lesson?>>
    func fetchLessonAndUnit(unitID: Unit.IdType) -> Promise<(FetchResult<Unit?>, FetchResult<Lesson?>)>
}

final class NewLessonProvider: NewLessonProviderProtocol {
    private let lessonsPersistenceService: LessonsPersistenceServiceProtocol
    private let lessonsNetworkService: LessonsNetworkServiceProtocol
    private let unitsPersistenceService: UnitsPersistenceServiceProtocol
    private let unitsNetworkService: UnitsNetworkServiceProtocol

    init(
        lessonsPersistenceService: LessonsPersistenceServiceProtocol,
        lessonsNetworkService: LessonsNetworkServiceProtocol,
        unitsPersistenceService: UnitsPersistenceServiceProtocol,
        unitsNetworkService: UnitsNetworkServiceProtocol
    ) {
        self.lessonsPersistenceService = lessonsPersistenceService
        self.lessonsNetworkService = lessonsNetworkService
        self.unitsPersistenceService = unitsPersistenceService
        self.unitsNetworkService = unitsNetworkService
    }

    // MARK: Public API

    func fetchLesson(id: Lesson.IdType) -> Promise<FetchResult<Lesson?>> {
        let persistenceServicePromise = self.guaranteeWithFallback(
            self.lessonsPersistenceService.fetch(ids: [id]),
            fallback: []
        )
        let networkServicePromise = self.guaranteeWithFallback(
            self.lessonsPersistenceService.fetch(ids: [id]),
            fallback: []
        )

        return Promise { seal in
            when(
                fulfilled: persistenceServicePromise,
                networkServicePromise
            ).then { cachedLessons, remoteLessons -> Promise<FetchResult<Lesson?>> in
                if let remoteLesson = remoteLessons.first {
                    let result = FetchResult<Lesson?>(value: remoteLesson, source: .remote)
                    return Promise.value(result)
                }

                let result = FetchResult<Lesson?>(value: cachedLessons.first, source: .cache)
                return Promise.value(result)
            }.done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchLessonAndUnit(unitID: Unit.IdType) -> Promise<(FetchResult<Unit?>, FetchResult<Lesson?>)> {
        return Promise { seal in
            when(
                fulfilled: self.unitsPersistenceService.fetch(id: unitID),
                self.unitsNetworkService.fetch(id: unitID)
            ).then { cachedUnit, remoteUnit -> Promise<(FetchResult<Unit?>, FetchResult<Lesson?>)> in
                if let remoteUnit = remoteUnit {
                    let result = FetchResult<Unit?>(value: remoteUnit, source: .remote)
                    return when(
                        fulfilled: Promise.value(result),
                        self.fetchLesson(id: remoteUnit.lessonId)
                    )
                }

                if let cachedUnit = cachedUnit {
                    let result = FetchResult<Unit?>(value: cachedUnit, source: .cache)
                    return when(
                        fulfilled: Promise.value(result),
                        self.fetchLesson(id: cachedUnit.lessonId)
                    )
                }

                let unitResult = FetchResult<Unit?>(value: nil, source: .cache)
                let lessonResult = FetchResult<Lesson?>(value: nil, source: .cache)
                return Promise.value((unitResult, lessonResult))
            }.done { unitResult, lessonResult in
                seal.fulfill((unitResult, lessonResult))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    // MARK: Private API

    private func guaranteeWithFallback<U: Thenable>(
        _ thenable: U,
        fallback: U.T
    ) -> Guarantee<U.T> {
        return Guarantee { seal in
            thenable.done { result in
                seal(result)
            }.catch { _ in
                seal(fallback)
            }
        }
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case fetchFailed
    }
}
