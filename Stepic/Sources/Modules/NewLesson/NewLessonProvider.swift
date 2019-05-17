import Foundation
import PromiseKit

protocol NewLessonProviderProtocol {
    func fetchLesson(id: Lesson.IdType) -> Promise<FetchResult<Lesson?>>
    func fetchLessonAndUnit(unitID: Unit.IdType) -> Promise<(FetchResult<Unit?>, FetchResult<Lesson?>)>
    func fetchSteps(ids: [Step.IdType]) -> Promise<FetchResult<[Step]?>>
}

final class NewLessonProvider: NewLessonProviderProtocol {
    private let lessonsPersistenceService: LessonsPersistenceServiceProtocol
    private let lessonsNetworkService: LessonsNetworkServiceProtocol
    private let unitsPersistenceService: UnitsPersistenceServiceProtocol
    private let unitsNetworkService: UnitsNetworkServiceProtocol
    private let stepsPersistenceService: StepsPersistenceServiceProtocol
    private let stepsNetworkService: StepsNetworkServiceProtocol

    init(
        lessonsPersistenceService: LessonsPersistenceServiceProtocol,
        lessonsNetworkService: LessonsNetworkServiceProtocol,
        unitsPersistenceService: UnitsPersistenceServiceProtocol,
        unitsNetworkService: UnitsNetworkServiceProtocol,
        stepsPersistenceService: StepsPersistenceServiceProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol
    ) {
        self.lessonsPersistenceService = lessonsPersistenceService
        self.lessonsNetworkService = lessonsNetworkService
        self.unitsPersistenceService = unitsPersistenceService
        self.unitsNetworkService = unitsNetworkService
        self.stepsPersistenceService = stepsPersistenceService
        self.stepsNetworkService = stepsNetworkService
    }

    // MARK: Public API

    func fetchLesson(id: Lesson.IdType) -> Promise<FetchResult<Lesson?>> {
        let persistenceServicePromise = Guarantee(self.lessonsPersistenceService.fetch(ids: [id]), fallback: nil)
        let networkServicePromise = Guarantee(self.lessonsNetworkService.fetch(ids: [id]), fallback: nil)

        return Promise { seal in
            when(
                fulfilled: persistenceServicePromise,
                networkServicePromise
            ).then { cachedLessons, remoteLessons -> Promise<FetchResult<Lesson?>> in
                if let remoteLesson = remoteLessons?.first {
                    let result = FetchResult<Lesson?>(value: remoteLesson, source: .remote)
                    return Promise.value(result)
                }

                let result = FetchResult<Lesson?>(value: cachedLessons?.first, source: .cache)
                return Promise.value(result)
            }.done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchLessonAndUnit(unitID: Unit.IdType) -> Promise<(FetchResult<Unit?>, FetchResult<Lesson?>)> {
        let persistenceServicePromise = Guarantee(self.unitsPersistenceService.fetch(ids: [unitID]), fallback: nil)
        let networkServicePromise = Guarantee(self.unitsNetworkService.fetch(ids: [unitID]), fallback: nil)

        return Promise { seal in
            when(
                fulfilled: persistenceServicePromise,
                networkServicePromise
            ).then { cachedUnits, remoteUnits -> Promise<(FetchResult<Unit?>, FetchResult<Lesson?>)> in
                if let remoteUnit = remoteUnits?.first {
                    let result = FetchResult<Unit?>(value: remoteUnit, source: .remote)
                    return when(
                        fulfilled: Promise.value(result),
                        self.fetchLesson(id: remoteUnit.lessonId)
                    )
                }

                if let cachedUnit = cachedUnits?.first {
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

    // swiftlint:disable:next discouraged_optional_collection
    func fetchSteps(ids: [Step.IdType]) -> Promise<FetchResult<[Step]?>> {
        let persistenceServicePromise = Guarantee(self.stepsPersistenceService.fetch(ids: ids), fallback: nil)
        let networkServicePromise = Guarantee(self.stepsNetworkService.fetch(ids: ids), fallback: nil)

        return Promise { seal in
            when(
                fulfilled: persistenceServicePromise,
                networkServicePromise
            ).then { cachedSteps, remoteSteps -> Promise<FetchResult<[Step]?>> in
                if let remoteSteps = remoteSteps {
                    let result = FetchResult<[Step]?>(value: remoteSteps, source: .remote)
                    return Promise.value(result)
                }

                let result = FetchResult<[Step]?>(value: cachedSteps, source: .cache)
                return Promise.value(result)
            }.done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case fetchFailed
    }
}
