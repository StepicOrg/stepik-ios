import Foundation
import PromiseKit

protocol LessonProviderProtocol {
    func fetchLesson(id: Lesson.IdType, dataSourceType: DataSourceType) -> Promise<Lesson?>
    func fetchLessonAndUnit(unitID: Unit.IdType, dataSourceType: DataSourceType) -> Promise<(Unit?, Lesson?)>
    func fetchSteps(ids: [Step.IdType], dataSourceType: DataSourceType) -> Promise<[Step]>
    func fetchAssignments(ids: [Assignment.IdType], dataSourceType: DataSourceType) -> Promise<[Assignment]>
    func fetchProgresses(ids: [Progress.IdType], dataSourceType: DataSourceType) -> Promise<[Progress]>

    func createView(stepID: Step.IdType, assignmentID: Assignment.IdType?) -> Promise<Void>
}

final class LessonProvider: LessonProviderProtocol {
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

    func fetchLesson(id: Lesson.IdType, dataSourceType: DataSourceType) -> Promise<Lesson?> {
        Promise { seal in
            firstly { () -> Promise<[Lesson]> in
                switch dataSourceType {
                case .remote:
                    return self.lessonsNetworkService.fetch(ids: [id])
                case .cache:
                    return self.lessonsPersistenceService.fetch(ids: [id])
                }
            }.done { lessons in
                seal.fulfill(lessons.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchLessonAndUnit(unitID: Unit.IdType, dataSourceType: DataSourceType) -> Promise<(Unit?, Lesson?)> {
        Promise { seal in
            firstly { () -> Promise<[Unit]> in
                switch dataSourceType {
                case .remote:
                    return self.unitsNetworkService.fetch(ids: [unitID])
                case .cache:
                    return self.unitsPersistenceService.fetch(ids: [unitID])
                }
            }.then { units -> Promise<(Unit?, Lesson?)> in
                if let unit = units.first {
                    return when(
                        fulfilled: Promise.value(unit as Unit?),
                        self.fetchLesson(id: unit.lessonId, dataSourceType: dataSourceType)
                    )
                } else {
                    return .value((nil, nil))
                }
            }.done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchSteps(ids: [Step.IdType], dataSourceType: DataSourceType) -> Promise<[Step]> {
        Promise { seal in
            firstly { () -> Promise<[Step]> in
                switch dataSourceType {
                case .remote:
                    return self.stepsNetworkService.fetch(ids: ids)
                case .cache:
                    return self.stepsPersistenceService.fetch(ids: ids)
                }
            }.done { steps in
                seal.fulfill(steps)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchAssignments(ids: [Assignment.IdType], dataSourceType: DataSourceType) -> Promise<[Assignment]> {
        Promise { seal in
            firstly { () -> Promise<[Assignment]> in
                switch dataSourceType {
                case .remote:
                    return self.assignmentsNetworkService.fetch(ids: ids)
                case .cache:
                    return self.assignmentsPersistenceService.fetch(ids: ids)
                }
            }.done { assignments in
                seal.fulfill(assignments)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchProgresses(ids: [Progress.IdType], dataSourceType: DataSourceType) -> Promise<[Progress]> {
        Promise { seal in
            firstly { () -> Promise<([Progress], Meta)> in
                switch dataSourceType {
                case .remote:
                    return self.progressesNetworkService.fetch(ids: ids, page: 1)
                case .cache:
                    return self.progressesPersistenceService.fetch(ids: ids, page: 1)
                }
            }.done { progresses, _ in
                seal.fulfill(progresses)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func createView(stepID: Step.IdType, assignmentID: Assignment.IdType?) -> Promise<Void> {
        Promise { seal in
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
