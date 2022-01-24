import Foundation
import PromiseKit

protocol CourseInfoTabSyllabusProviderProtocol {
    func fetchSections(for course: Course, shouldUseNetwork: Bool) -> Promise<[Section]>
    func fetchUnitsWithLessons(for section: Section, shouldUseNetwork: Bool) -> Promise<[Unit]>
    func fetchExamData(for section: Section) -> Promise<Section>
}

final class CourseInfoTabSyllabusProvider: CourseInfoTabSyllabusProviderProtocol {
    private static let networkFetchChunkSize = 100

    private let sectionsPersistenceService: SectionsPersistenceServiceProtocol
    private let sectionsNetworkService: SectionsNetworkServiceProtocol

    private let progressesPersistenceService: ProgressesPersistenceServiceProtocol
    private let progressesNetworkService: ProgressesNetworkServiceProtocol

    private let unitsPersistenceService: UnitsPersistenceServiceProtocol
    private let unitsNetworkService: UnitsNetworkServiceProtocol

    private let lessonsPersistenceService: LessonsPersistenceServiceProtocol
    private let lessonsNetworkService: LessonsNetworkServiceProtocol

    private let examSessionsNetworkService: ExamSessionsNetworkServiceProtocol
    private let proctorSessionsNetworkService: ProctorSessionsNetworkServiceProtocol

    init(
        sectionsPersistenceService: SectionsPersistenceServiceProtocol,
        sectionsNetworkService: SectionsNetworkServiceProtocol,
        progressesPersistenceService: ProgressesPersistenceServiceProtocol,
        progressesNetworkService: ProgressesNetworkServiceProtocol,
        unitsPersistenceService: UnitsPersistenceServiceProtocol,
        unitsNetworkService: UnitsNetworkServiceProtocol,
        lessonsPersistenceService: LessonsPersistenceServiceProtocol,
        lessonsNetworkService: LessonsNetworkServiceProtocol,
        examSessionsNetworkService: ExamSessionsNetworkServiceProtocol,
        proctorSessionsNetworkService: ProctorSessionsNetworkServiceProtocol
    ) {
        self.sectionsPersistenceService = sectionsPersistenceService
        self.sectionsNetworkService = sectionsNetworkService
        self.progressesPersistenceService = progressesPersistenceService
        self.progressesNetworkService = progressesNetworkService
        self.unitsPersistenceService = unitsPersistenceService
        self.unitsNetworkService = unitsNetworkService
        self.lessonsPersistenceService = lessonsPersistenceService
        self.lessonsNetworkService = lessonsNetworkService
        self.examSessionsNetworkService = examSessionsNetworkService
        self.proctorSessionsNetworkService = proctorSessionsNetworkService
    }

    func fetchSections(for course: Course, shouldUseNetwork: Bool) -> Promise<[Section]> {
        Promise { seal in
            firstly {
                shouldUseNetwork
                    ? self.sectionsNetworkService.fetch(ids: course.sectionsArray)
                    : self.sectionsPersistenceService.fetch(ids: course.sectionsArray)
            }.then { sections -> Promise<([Section], [Progress])> in
                let progressesIDs = sections.compactMap { $0.progressId }
                let progressPromise = shouldUseNetwork
                    ? self.progressesNetworkService.fetch(ids: progressesIDs, page: 1)
                    : self.progressesPersistenceService.fetch(ids: progressesIDs, page: 1)
                return progressPromise.map { (sections, $0.0) }
            }.done { sections, progresses in
                course.sections = sections
                let progressesMap: [Progress.IdType: Progress] = progresses
                    .reduce(into: [:]) { $0[$1.id] = $1 }

                for i in 0..<sections.count {
                    if let progressID = sections[i].progressId {
                        sections[i].progress = progressesMap[progressID]
                    }
                }

                seal.fulfill(sections)
                CoreDataHelper.shared.save()
            }.catch { _ in
                shouldUseNetwork
                    ? seal.reject(Error.sectionsNetworkFetchFailed)
                    : seal.reject(Error.sectionsPersistenceFetchFailed)
            }
        }
    }

    func fetchUnitsWithLessons(for section: Section, shouldUseNetwork: Bool) -> Promise<[Unit]> {
        Promise { seal in
            firstly {
                shouldUseNetwork
                    ? self.fetchUnitsWithLessonsFromNetwork(unitsIDs: section.unitsArray)
                    : self.fetchUnitsWithLessonsLocally(unitsIDs: section.unitsArray)
            }.done { units in
                section.units = units
                seal.fulfill(units)

                CoreDataHelper.shared.save()
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func fetchExamData(for section: Section) -> Promise<Section> {
        Promise { seal in
            let examSessionPromise: Promise<ExamSession?> = {
                if let examSessionID = section.examSessionId {
                    return self.examSessionsNetworkService.fetch(id: examSessionID)
                }
                return .value(nil)
            }()

            let proctorSessionPromise: Promise<ProctorSession?> = {
                if let proctorSessionID = section.proctorSessionId {
                    return self.proctorSessionsNetworkService.fetch(id: proctorSessionID)
                }
                return .value(nil)
            }()

            when(fulfilled: examSessionPromise, proctorSessionPromise).done { examSession, proctorSession in
                section.examSession = examSession
                section.proctorSession = proctorSession

                CoreDataHelper.shared.save()

                seal.fulfill(section)
            }.catch { _ in
                seal.reject(Error.examNetworkFetchFailed)
            }
        }
    }

    private func fetchUnitsWithLessonsLocally(unitsIDs: [Unit.IdType]) -> Promise<[Unit]> {
        Promise { seal in
            self.unitsPersistenceService.fetch(ids: unitsIDs).then {
                units -> Promise<([Unit], [Lesson], [Progress])> in
                let lessonsIDs = units.map { $0.lessonId }
                let progressesIDs = units.compactMap { $0.progressId }

                return when(
                    fulfilled: self.lessonsPersistenceService.fetch(ids: lessonsIDs),
                    self.progressesPersistenceService.fetch(ids: progressesIDs, page: 1)
                ).map { (units, $0, $1.0) }
            }.then { units, lessons, progresses -> Guarantee<[Unit]> in
                self.mergeAsync(units: units, progresses: progresses, lessons: lessons)
            }.done { units in
                let orderedUnits = units.reordered(order: unitsIDs, transform: { $0.id })
                seal.fulfill(orderedUnits)
            }.catch { _ in
                seal.reject(Error.unitsPersistenceFetchFailed)
            }
        }
    }

    private func fetchUnitsWithLessonsFromNetwork(unitsIDs: [Unit.IdType]) -> Promise<[Unit]> {
        func splitOnChunks<T>(array: [T], size: Int) -> [[T]] {
            stride(from: 0, to: array.count, by: size).map {
                Array(array[$0..<min($0 + size, array.count)])
            }
        }

        return Promise { seal in
            let chunkedUnitsIDs = splitOnChunks(
                array: unitsIDs,
                size: CourseInfoTabSyllabusProvider.networkFetchChunkSize
            )
            let unitsPromises = chunkedUnitsIDs.map { self.unitsNetworkService.fetch(ids: $0) }
            when(fulfilled: unitsPromises).then {
                chunkedUnits -> Promise<([Unit], [[Progress]], [[Lesson]])> in
                let units = Array(chunkedUnits.joined())

                let progressesIDs = splitOnChunks(
                    array: units.compactMap { $0.progressId },
                    size: CourseInfoTabSyllabusProvider.networkFetchChunkSize
                )

                let lessonsIDs = splitOnChunks(
                    array: units.map { $0.lessonId },
                    size: CourseInfoTabSyllabusProvider.networkFetchChunkSize
                )

                let progressesPromise = when(
                    fulfilled: progressesIDs.map { progressID in
                        self.progressesNetworkService.fetch(ids: progressID, page: 1)
                    }
                )

                let lessonsPromise = when(
                    fulfilled: lessonsIDs.map { lessonID in
                        self.lessonsNetworkService.fetch(ids: lessonID)
                    }
                )

                return when(fulfilled: progressesPromise, lessonsPromise).map { (units, $0.map { $0.0 }, $1) }
            }.then { units, chunkedProgresses, chunkedLessons -> Guarantee<[Unit]> in
                let progresses = Array(chunkedProgresses.joined())
                let lessons = Array(chunkedLessons.joined())

                return self.mergeAsync(units: units, progresses: progresses, lessons: lessons)
            }.done { units in
                let orderedUnits = units.reordered(order: unitsIDs, transform: { $0.id })
                seal.fulfill(orderedUnits)
            }.catch { _ in
                seal.reject(Error.unitsNetworkFetchFailed)
            }
        }
    }

    private func mergeAsync(
        units: [Unit],
        progresses: [Progress],
        lessons: [Lesson]
    ) -> Guarantee<[Unit]> {
        Guarantee { seal in
            let progressesMap: [Progress.IdType: Progress] = progresses.reduce(into: [:]) { $0[$1.id] = $1 }
            let lessonsMap: [Lesson.IdType: Lesson] = lessons.reduce(into: [:]) { $0[$1.id] = $1 }

            for i in 0..<units.count {
                if let progressID = units[i].progressId {
                    units[i].progress = progressesMap[progressID]
                }

                units[i].lesson = lessonsMap[units[i].lessonId]
            }

            seal(units)
            CoreDataHelper.shared.save()
        }
    }

    enum Error: Swift.Error {
        case sectionsPersistenceFetchFailed
        case sectionsNetworkFetchFailed
        case unitsPersistenceFetchFailed
        case unitsNetworkFetchFailed
        case stepsNetworkFetchFailed
        case examNetworkFetchFailed
    }
}
