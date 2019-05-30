import Foundation
import PromiseKit

protocol NewLessonProviderProtocol {
    func fetchLesson(id: Lesson.IdType) -> Promise<FetchResult<Lesson?>>
    func fetchLessonAndUnit(unitID: Unit.IdType) -> Promise<(FetchResult<Unit?>, FetchResult<Lesson?>)>
    func fetchSteps(ids: [Step.IdType]) -> Promise<FetchResult<[Step]?>>
    func fetchAssignments(ids: [Assignment.IdType]) -> Promise<FetchResult<[Assignment]?>>
    func fetchProgresses(ids: [Progress.IdType]) -> Promise<FetchResult<[Progress]?>>

    func createView(stepID: Step.IdType, assignmentID: Assignment.IdType?) -> Promise<Void>
}

final class NewLessonProvider: NewLessonProviderProtocol {
    private let lessonsPersistenceService: LessonsPersistenceServiceProtocol
    private let lessonsNetworkService: LessonsNetworkServiceProtocol
    private let unitsPersistenceService: UnitsPersistenceServiceProtocol
    private let unitsNetworkService: UnitsNetworkServiceProtocol
    private let stepsPersistenceService: StepsPersistenceServiceProtocol
    private let stepsNetworkService: StepsNetworkServiceProtocol
    private let assignmentsPersistenceService: AssignmentsPersistenceServiceProtocol
    private let assignmentsNetworkService: AssignmentsNetworkServiceProtocol
    private let progressesPersistenceService: ProgressesPersistenceServiceProtocol
    private let progressesNetworkService: ProgressesNetworkServiceProtocol
    private let viewsNetworkService: ViewsNetworkServiceProtocol

    init(
        lessonsPersistenceService: LessonsPersistenceServiceProtocol,
        lessonsNetworkService: LessonsNetworkServiceProtocol,
        unitsPersistenceService: UnitsPersistenceServiceProtocol,
        unitsNetworkService: UnitsNetworkServiceProtocol,
        stepsPersistenceService: StepsPersistenceServiceProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol,
        assignmentsNetworkService: AssignmentsNetworkServiceProtocol,
        assignmentsPersistenceService: AssignmentsPersistenceServiceProtocol,
        progressesPersistenceService: ProgressesPersistenceServiceProtocol,
        progressesNetworkService: ProgressesNetworkServiceProtocol,
        viewsNetworkService: ViewsNetworkServiceProtocol
    ) {
        self.lessonsPersistenceService = lessonsPersistenceService
        self.lessonsNetworkService = lessonsNetworkService
        self.unitsPersistenceService = unitsPersistenceService
        self.unitsNetworkService = unitsNetworkService
        self.stepsPersistenceService = stepsPersistenceService
        self.stepsNetworkService = stepsNetworkService
        self.assignmentsNetworkService = assignmentsNetworkService
        self.assignmentsPersistenceService = assignmentsPersistenceService
        self.progressesPersistenceService = progressesPersistenceService
        self.progressesNetworkService = progressesNetworkService
        self.viewsNetworkService = viewsNetworkService
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

    func fetchAssignments(ids: [Assignment.IdType]) -> Promise<FetchResult<[Assignment]?>> {
        let persistenceServicePromise = Guarantee(self.assignmentsPersistenceService.fetch(ids: ids), fallback: nil)
        let networkServicePromise = Guarantee(self.assignmentsNetworkService.fetch(ids: ids), fallback: nil)

        return Promise { seal in
            when(
                fulfilled: persistenceServicePromise,
                networkServicePromise
            ).then { cachedAssignments, remoteAssignments -> Promise<FetchResult<[Assignment]?>> in
                if let remoteAssignments = remoteAssignments {
                    let result = FetchResult<[Assignment]?>(value: remoteAssignments, source: .remote)
                    return Promise.value(result)
                }

                let result = FetchResult<[Assignment]?>(value: cachedAssignments, source: .cache)
                return Promise.value(result)
            }.done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchProgresses(ids: [Progress.IdType]) -> Promise<FetchResult<[Progress]?>> {
        let persistenceServicePromise = Guarantee(
            self.progressesPersistenceService.fetch(ids: ids, page: 1),
            fallback: nil
        )
        let networkServicePromise = Guarantee(
            self.progressesNetworkService.fetch(ids: ids, page: 1),
            fallback: nil
        )

        return Promise { seal in
            when(
                fulfilled: persistenceServicePromise,
                networkServicePromise
            ).then { cachedProgresses, remoteProgresses -> Promise<FetchResult<[Progress]?>> in
                if let remoteProgresses = remoteProgresses?.0 {
                    let result = FetchResult<[Progress]?>(value: remoteProgresses, source: .remote)
                    return Promise.value(result)
                }

                let result = FetchResult<[Progress]?>(value: cachedProgresses?.0, source: .cache)
                return Promise.value(result)
            }.done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func createView(stepID: Step.IdType, assignmentID: Assignment.IdType?) -> Promise<Void> {
        return Promise { seal in
            self.viewsNetworkService.create(step: stepID, assignment: assignmentID).done {
                seal.fulfill(())
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
