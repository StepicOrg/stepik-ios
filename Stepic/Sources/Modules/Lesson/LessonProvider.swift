import Foundation
import PromiseKit

protocol LessonProviderProtocol {
    func fetchLesson(id: Lesson.IdType, dataSourceType: DataSourceType) -> Promise<Lesson?>
    func fetchLessonAndUnit(unitID: Unit.IdType, dataSourceType: DataSourceType) -> Promise<(Unit?, Lesson?)>
    func fetchSteps(ids: [Step.IdType], dataSourceType: DataSourceType) -> Promise<[Step]>
    func fetchSteps(ids: [Step.IdType]) -> Promise<FetchResult<[Step]?>>
    func fetchAssignments(ids: [Assignment.IdType], dataSourceType: DataSourceType) -> Promise<[Assignment]>
    func fetchProgresses(ids: [Progress.IdType], dataSourceType: DataSourceType) -> Promise<[Progress]>
    func fetchProgresses(ids: [Progress.IdType]) -> Promise<FetchResult<[Progress]?>>
    func fetchSection(id: Section.IdType, dataSourceType: DataSourceType) -> Promise<Section?>
    func fetchCourse(id: Course.IdType, dataSourceType: DataSourceType) -> Promise<Course?>

    func createView(stepID: Step.IdType, assignmentID: Assignment.IdType?) -> Promise<Void>
}

extension LessonProviderProtocol {
    func fetchLessonFromCacheOrNetwork(id: Lesson.IdType) -> Promise<Lesson?> {
        self.fetchLesson(id: id, dataSourceType: .cache).then { cachedLessonOrNil -> Promise<Lesson?> in
            if let cachedLesson = cachedLessonOrNil {
                return .value(cachedLesson)
            } else {
                return self.fetchLesson(id: id, dataSourceType: .remote)
            }
        }
    }

    func fetchSectionFromCacheOrNetwork(id: Section.IdType) -> Promise<Section?> {
        self.fetchSection(id: id, dataSourceType: .cache).then { cachedSectionOrNil -> Promise<Section?> in
            if let cachedSection = cachedSectionOrNil {
                return .value(cachedSection)
            } else {
                return self.fetchSection(id: id, dataSourceType: .remote)
            }
        }
    }

    func fetchCourseFromCacheOrNetwork(id: Course.IdType) -> Promise<Course?> {
        self.fetchCourse(id: id, dataSourceType: .cache).then { cachedCourseOrNil -> Promise<Course?> in
            if let cachedCourse = cachedCourseOrNil {
                return .value(cachedCourse)
            } else {
                return self.fetchCourse(id: id, dataSourceType: .remote)
            }
        }
    }
}

final class LessonProvider: LessonProviderProtocol {
    private let lessonsPersistenceService: LessonsPersistenceServiceProtocol
    private let lessonsNetworkService: LessonsNetworkServiceProtocol
    private let sectionsPersistenceService: SectionsPersistenceServiceProtocol
    private let sectionsNetworkService: SectionsNetworkServiceProtocol
    private let unitsPersistenceService: UnitsPersistenceServiceProtocol
    private let unitsNetworkService: UnitsNetworkServiceProtocol
    private let stepsPersistenceService: StepsPersistenceServiceProtocol
    private let stepsNetworkService: StepsNetworkServiceProtocol
    private let assignmentsPersistenceService: AssignmentsPersistenceServiceProtocol
    private let assignmentsNetworkService: AssignmentsNetworkServiceProtocol
    private let progressesPersistenceService: ProgressesPersistenceServiceProtocol
    private let progressesNetworkService: ProgressesNetworkServiceProtocol
    private let viewsNetworkService: ViewsNetworkServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let coursesNetworkService: CoursesNetworkServiceProtocol

    init(
        lessonsPersistenceService: LessonsPersistenceServiceProtocol,
        lessonsNetworkService: LessonsNetworkServiceProtocol,
        sectionsPersistenceService: SectionsPersistenceServiceProtocol,
        sectionsNetworkService: SectionsNetworkServiceProtocol,
        unitsPersistenceService: UnitsPersistenceServiceProtocol,
        unitsNetworkService: UnitsNetworkServiceProtocol,
        stepsPersistenceService: StepsPersistenceServiceProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol,
        assignmentsNetworkService: AssignmentsNetworkServiceProtocol,
        assignmentsPersistenceService: AssignmentsPersistenceServiceProtocol,
        progressesPersistenceService: ProgressesPersistenceServiceProtocol,
        progressesNetworkService: ProgressesNetworkServiceProtocol,
        viewsNetworkService: ViewsNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol
    ) {
        self.lessonsPersistenceService = lessonsPersistenceService
        self.lessonsNetworkService = lessonsNetworkService
        self.sectionsPersistenceService = sectionsPersistenceService
        self.sectionsNetworkService = sectionsNetworkService
        self.unitsPersistenceService = unitsPersistenceService
        self.unitsNetworkService = unitsNetworkService
        self.stepsPersistenceService = stepsPersistenceService
        self.stepsNetworkService = stepsNetworkService
        self.assignmentsNetworkService = assignmentsNetworkService
        self.assignmentsPersistenceService = assignmentsPersistenceService
        self.progressesPersistenceService = progressesPersistenceService
        self.progressesNetworkService = progressesNetworkService
        self.viewsNetworkService = viewsNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.coursesNetworkService = coursesNetworkService
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

    func fetchAssignments(ids: [Assignment.IdType], dataSourceType: DataSourceType) -> Promise<[Assignment]> {
        Promise { seal in
            firstly { () -> Promise<[Assignment]> in
                switch dataSourceType {
                case .remote:
                    return self.assignmentsNetworkService.fetch(ids: ids)
                case .cache:
                    return Promise(self.assignmentsPersistenceService.fetch(ids: ids))
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
                let result = progresses.reordered(order: ids, transform: { $0.id })
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

    func fetchSection(id: Section.IdType, dataSourceType: DataSourceType) -> Promise<Section?> {
        Promise { seal in
            firstly { () -> Promise<[Section]> in
                switch dataSourceType {
                case .remote:
                    return self.sectionsNetworkService.fetch(ids: [id])
                case .cache:
                    return self.sectionsPersistenceService.fetch(ids: [id])
                }
            }.done { sections in
                seal.fulfill(sections.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchCourse(id: Course.IdType, dataSourceType: DataSourceType) -> Promise<Course?> {
        switch dataSourceType {
        case .remote:
            return self.coursesNetworkService.fetch(id: id)
        case .cache:
            return self.coursesPersistenceService.fetch(id: id)
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
