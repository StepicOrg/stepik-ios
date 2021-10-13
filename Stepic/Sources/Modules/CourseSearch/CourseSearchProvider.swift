import Foundation
import PromiseKit

protocol CourseSearchProviderProtocol {
    func fetchCourse() -> Promise<Course?>
    func fetchSuggestions(fetchLimit: Int) -> Guarantee<[SearchQueryResult]>

    func searchInCourse(query: String, page: Int) -> Promise<([SearchResultPlainObject], Meta)>
}

final class CourseSearchProvider: CourseSearchProviderProtocol {
    private let courseID: Course.IdType

    private let searchResultsRepository: SearchResultsRepositoryProtocol
    private let searchQueryResultsPersistenceService: SearchQueryResultsPersistenceServiceProtocol

    private let coursesNetworkService: CoursesNetworkServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol

    private let stepsNetworkService: StepsNetworkServiceProtocol
    private let stepsPersistenceService: StepsPersistenceServiceProtocol

    private let lessonsNetworkService: LessonsNetworkServiceProtocol
    private let lessonsPersistenceService: LessonsPersistenceServiceProtocol

    private let unitsNetworkService: UnitsNetworkServiceProtocol
    private let unitsPersistenceService: UnitsPersistenceServiceProtocol

    private let sectionsNetworkService: SectionsNetworkServiceProtocol
    private let sectionsPersistenceService: SectionsPersistenceServiceProtocol

    private let progressesNetworkService: ProgressesNetworkServiceProtocol
    private let progressesPersistenceServiceProtocol: ProgressesPersistenceServiceProtocol

    private let usersNetworkService: UsersNetworkServiceProtocol
    private let usersPersistenceService: UsersPersistenceServiceProtocol

    init(
        courseID: Course.IdType,
        searchResultsRepository: SearchResultsRepositoryProtocol,
        searchQueryResultsPersistenceService: SearchQueryResultsPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol,
        stepsPersistenceService: StepsPersistenceServiceProtocol,
        lessonsNetworkService: LessonsNetworkServiceProtocol,
        lessonsPersistenceService: LessonsPersistenceServiceProtocol,
        unitsNetworkService: UnitsNetworkServiceProtocol,
        unitsPersistenceService: UnitsPersistenceServiceProtocol,
        sectionsNetworkService: SectionsNetworkServiceProtocol,
        sectionsPersistenceService: SectionsPersistenceServiceProtocol,
        progressesNetworkService: ProgressesNetworkServiceProtocol,
        progressesPersistenceServiceProtocol: ProgressesPersistenceServiceProtocol,
        usersNetworkService: UsersNetworkServiceProtocol,
        usersPersistenceService: UsersPersistenceServiceProtocol
    ) {
        self.courseID = courseID
        self.searchResultsRepository = searchResultsRepository
        self.searchQueryResultsPersistenceService = searchQueryResultsPersistenceService
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.stepsNetworkService = stepsNetworkService
        self.stepsPersistenceService = stepsPersistenceService
        self.lessonsNetworkService = lessonsNetworkService
        self.lessonsPersistenceService = lessonsPersistenceService
        self.unitsNetworkService = unitsNetworkService
        self.unitsPersistenceService = unitsPersistenceService
        self.sectionsNetworkService = sectionsNetworkService
        self.sectionsPersistenceService = sectionsPersistenceService
        self.progressesNetworkService = progressesNetworkService
        self.progressesPersistenceServiceProtocol = progressesPersistenceServiceProtocol
        self.usersNetworkService = usersNetworkService
        self.usersPersistenceService = usersPersistenceService
    }

    func fetchCourse() -> Promise<Course?> {
        self.coursesPersistenceService.fetch(id: self.courseID).then { cachedCourse -> Promise<Course?> in
            if let cachedCourse = cachedCourse {
                return .value(cachedCourse)
            }
            return self.coursesNetworkService.fetch(id: self.courseID)
        }
    }

    func fetchSuggestions(fetchLimit: Int) -> Guarantee<[SearchQueryResult]> {
        self.searchQueryResultsPersistenceService.fetch(courseID: self.courseID, fetchLimit: fetchLimit)
    }

    func searchInCourse(query: String, page: Int) -> Promise<([SearchResultPlainObject], Meta)> {
        var resultMeta = Meta.oneAndOnlyPage

        return Promise { seal in
            self.searchResultsRepository.searchInCourse(
                self.courseID,
                query: query,
                page: page,
                dataSourceType: .remote
            ).then { searchResults, meta -> Promise<[SearchResult]> in
                resultMeta = meta

                let targetOrder = searchResults.map(\.id)
                let targetIDs = Set(targetOrder)

                return self.searchQueryResultsPersistenceService
                    .fetch(query: query, courseID: self.courseID)
                    .compactMap { $0 }
                    .map { searchQueryResult -> [SearchResult] in
                        searchQueryResult
                            .searchResults
                            .filter { targetIDs.contains($0.id) }
                            .reordered(order: targetOrder, transform: { $0.id })
                    }
            }.then { searchResults -> Guarantee<[SearchResult]> in
                self.fetchAndMergeGraphData(searchResults)
            }.then { searchResults -> Guarantee<[SearchResult]> in
                self.fetchAndMergeSteps(searchResults)
            }.then { searchResults -> Guarantee<[SearchResult]> in
                self.fetchAndMergeUsers(searchResults)
            }.done { searchResults in
                let plainObjects = searchResults.map(\.plainObject)
                seal.fulfill((plainObjects, resultMeta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    // MARK: Private API

    private func fetchAndMergeGraphData(_ searchResults: [SearchResult]) -> Guarantee<[SearchResult]> {
        let lessonsIDs = Set(searchResults.compactMap(\.lessonID))

        if lessonsIDs.isEmpty {
            return .value(searchResults)
        }

        var resultLessons = [Lesson]()
        var resultUnits = [Unit]()
        var resultUnitsProgresses = [Progress]()
        var resultSections = [Section]()

        return Guarantee { seal in
            self.fetchLessons(Array(lessonsIDs)).then { lessons -> Guarantee<[Unit]> in
                resultLessons = lessons

                let unitsIDs = Set(lessons.flatMap(\.unitsArray))
                return self.fetchUnits(Array(unitsIDs))
            }.then { units -> Guarantee<[Progress]> in
                resultUnits = units

                let progressesIDs = units.compactMap(\.progressId)
                return self.fetchProgresses(Array(progressesIDs))
            }.then { progresses -> Guarantee<[Section]> in
                resultUnitsProgresses = progresses

                let sectionsIDs = Set(resultUnits.map(\.sectionId))
                return self.fetchSections(Array(sectionsIDs))
            }.then { sections -> Guarantee<Course?> in
                resultSections = sections
                return Guarantee { seal in
                    self.fetchCourse().done { seal($0) }.catch { _ in seal(nil) }
                }
            }.done { course in
                guard let course = course else {
                    return seal(searchResults)
                }

                let courseSectionsIDs = Set(course.sectionsArray)
                resultSections = resultSections.filter { courseSectionsIDs.contains($0.id) }

                let courseUnitsIDs = Set(resultSections.flatMap(\.unitsArray))
                resultUnits = resultUnits.filter { courseUnitsIDs.contains($0.id) }

                let lessonsMap = Dictionary(resultLessons.map({ ($0.id, $0) }), uniquingKeysWith: { first, _ in first })
                let unitsMap = Dictionary(resultUnits.map({ ($0.id, $0) }), uniquingKeysWith: { first, _ in first })
                let unitsProgressesMap = Dictionary(
                    resultUnitsProgresses.map({ ($0.id, $0) }),
                    uniquingKeysWith: { first, _ in first }
                )
                let sectionsMap = Dictionary(
                    resultSections.map({ ($0.id, $0) }),
                    uniquingKeysWith: { first, _ in first }
                )

                CoreDataHelper.shared.context.performChanges {
                    for searchResult in searchResults {
                        guard let lessonID = searchResult.lessonID,
                              let lesson = lessonsMap[lessonID] else {
                            continue
                        }

                        searchResult.lesson = lesson

                        guard let unitID = lesson.unitsArray.first(where: { courseUnitsIDs.contains($0) }),
                              let unit = unitsMap[unitID] else {
                            continue
                        }

                        lesson.unit = unit

                        if let progressID = unit.progressId,
                           let progress = unitsProgressesMap[progressID] {
                            unit.progress = progress
                        }

                        if let section = sectionsMap[unit.sectionId] {
                            unit.section = section
                        }
                    }

                    seal(searchResults)
                }
            }
        }
    }

    private func fetchLessons(_ ids: [Lesson.IdType]) -> Guarantee<[Lesson]> {
        firstly { () -> Guarantee<[Lesson]> in
            Guarantee(self.lessonsPersistenceService.fetch(ids: ids), fallback: nil).map { $0 ?? [] }
        }.then { cachedLessons -> Guarantee<[Lesson]> in
            if Set(ids) == Set(cachedLessons.map(\.id)) {
                return .value(cachedLessons)
            } else {
                return Guarantee(self.lessonsNetworkService.fetch(ids: ids), fallback: nil).map { $0 ?? cachedLessons }
            }
        }
    }

    private func fetchUnits(_ ids: [Unit.IdType]) -> Guarantee<[Unit]> {
        firstly { () -> Guarantee<[Unit]> in
            Guarantee(self.unitsPersistenceService.fetch(ids: ids), fallback: nil).map { $0 ?? [] }
        }.then { cachedUnits -> Guarantee<[Unit]> in
            if Set(ids) == Set(cachedUnits.map(\.id)) {
                return .value(cachedUnits)
            } else {
                return Guarantee(self.unitsNetworkService.fetch(ids: ids), fallback: nil).map { $0 ?? cachedUnits }
            }
        }
    }

    private func fetchSections(_ ids: [Section.IdType]) -> Guarantee<[Section]> {
        firstly { () -> Guarantee<[Section]> in
            Guarantee(self.sectionsPersistenceService.fetch(ids: ids), fallback: nil).map { $0 ?? [] }
        }.then { cachedSections -> Guarantee<[Section]> in
            if Set(ids) == Set(cachedSections.map(\.id)) {
                return .value(cachedSections)
            } else {
                return Guarantee(
                    self.sectionsNetworkService.fetch(ids: ids),
                    fallback: nil
                ).map { $0 ?? cachedSections }
            }
        }
    }

    private func fetchProgresses(_ ids: [Progress.IdType]) -> Guarantee<[Progress]> {
        firstly { () -> Guarantee<[Progress]> in
            Guarantee(
                self.progressesPersistenceServiceProtocol.fetch(ids: ids, page: 1),
                fallback: nil
            ).map { $0?.0 ?? [] }
        }.then { cachedProgresses -> Guarantee<[Progress]> in
            if Set(ids) == Set(cachedProgresses.map(\.id)) {
                return .value(cachedProgresses)
            } else {
                return Guarantee(
                    self.progressesNetworkService.fetch(ids: ids),
                    fallback: nil
                ).map { $0 ?? cachedProgresses }
            }
        }
    }

    private func fetchAndMergeSteps(_ searchResults: [SearchResult]) -> Guarantee<[SearchResult]> {
        let stepsIDs = Set(searchResults.compactMap(\.stepID))

        if stepsIDs.isEmpty {
            return .value(searchResults)
        }

        return Guarantee { seal in
            self.fetchSteps(Array(stepsIDs)).done { steps in
                if steps.isEmpty {
                    return seal(searchResults)
                }

                let stepsMap = Dictionary(steps.map({ ($0.id, $0) }), uniquingKeysWith: { first, _ in first })

                CoreDataHelper.shared.context.performChanges {
                    for searchResult in searchResults {
                        if let stepID = searchResult.stepID,
                           let step = stepsMap[stepID] {
                            searchResult.step = step
                        }
                    }

                    seal(searchResults)
                }
            }
        }
    }

    private func fetchSteps(_ ids: [Step.IdType]) -> Guarantee<[Step]> {
        firstly { () -> Guarantee<[Step]> in
            Guarantee(self.stepsPersistenceService.fetch(ids: ids), fallback: nil).map { $0 ?? [] }
        }.then { cachedSteps -> Guarantee<[Step]> in
            if Set(ids) == Set(cachedSteps.map(\.id)) {
                return .value(cachedSteps)
            } else {
                return Guarantee(self.stepsNetworkService.fetch(ids: ids), fallback: nil).map { $0 ?? cachedSteps }
            }
        }
    }

    private func fetchAndMergeUsers(_ searchResults: [SearchResult]) -> Guarantee<[SearchResult]> {
        let usersIDs = Set(searchResults.compactMap(\.commentUserID))

        if usersIDs.isEmpty {
            return .value(searchResults)
        }

        return Guarantee { seal in
            self.fetchUsers(Array(usersIDs)).done { users in
                if users.isEmpty {
                    return seal(searchResults)
                }

                let usersMap = Dictionary(users.map({ ($0.id, $0) }), uniquingKeysWith: { first, _ in first })

                CoreDataHelper.shared.context.performChanges {
                    for searchResult in searchResults {
                        if let commentUserID = searchResult.commentUserID,
                           let commentUser = usersMap[commentUserID] {
                            searchResult.commentUser = commentUser
                        }
                    }

                    seal(searchResults)
                }
            }
        }
    }

    private func fetchUsers(_ ids: [User.IdType]) -> Guarantee<[User]> {
        self.usersPersistenceService.fetch(ids: ids).then { cachedUsers -> Guarantee<[User]> in
            if Set(ids) == Set(cachedUsers.map(\.id)) {
                return .value(cachedUsers)
            } else {
                return Guarantee(
                    self.usersNetworkService.fetch(ids: ids),
                    fallback: nil
                ).map { $0 ?? cachedUsers }
            }
        }
    }
}
