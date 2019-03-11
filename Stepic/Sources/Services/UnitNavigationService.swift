import Foundation
import PromiseKit

enum UnitNavigationDirection {
    case next
    case previous
}

protocol UnitNavigationServiceProtocol: class {
    func findUnitForNavigation(from unit: Unit.IdType, direction: UnitNavigationDirection) -> Promise<Unit?>
}

final class UnitNavigationService: UnitNavigationServiceProtocol {
    private let sectionsPersistenceService: SectionsPersistenceServiceProtocol
    private let sectionsNetworkService: SectionsNetworkServiceProtocol
    private let unitsPersistenceService: UnitsPersistenceServiceProtocol
    private let unitsNetworkService: UnitsNetworkServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let coursesNetworkService: CoursesNetworkServiceProtocol

    init(
        sectionsPersistenceService: SectionsPersistenceServiceProtocol,
        sectionsNetworkService: SectionsNetworkServiceProtocol,
        unitsPersistenceService: UnitsPersistenceServiceProtocol,
        unitsNetworkService: UnitsNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol
    ) {
        self.sectionsPersistenceService = sectionsPersistenceService
        self.sectionsNetworkService = sectionsNetworkService
        self.unitsPersistenceService = unitsPersistenceService
        self.unitsNetworkService = unitsNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.coursesNetworkService = coursesNetworkService
    }

    func findUnitForNavigation(from unit: Unit.IdType, direction: UnitNavigationDirection) -> Promise<Unit?> {
        return self.getUnitFromCacheOrNetwork(id: unit).then { unit -> Promise<(Unit?, Section?)> in
            guard let unit = unit else {
                return Promise.value((nil, nil))
            }

            return self.getSectionFromCacheOrNetwork(id: unit.sectionId).map { (unit, $0) }
        }.then { unit, section -> Promise<Unit?> in
            guard let section = section, let unit = unit else {
                return Promise.value(nil)
            }

            unit.section = section
            CoreDataHelper.instance.save()

            // Cause unit & section have 1-indexed position in API
            let unitPosition = unit.position - 1
            let sectionPosition = section.position - 1

            let shouldLookUpInPreviousSection = unitPosition == 0
                && direction == .previous
            let shouldLookUpInNextSection = unitPosition == (section.unitsArray.count - 1)
                && direction == .next
            if shouldLookUpInPreviousSection || shouldLookUpInNextSection {
                return self.findUnitInAnotherSections(
                    courseID: section.courseId,
                    sectionPosition: sectionPosition,
                    direction: direction
                )
            } else {
                return self.findUnitInCurrentSection(
                    section,
                    unitPosition: unitPosition,
                    direction: direction
                )
            }
        }
    }

    private func findUnitInCurrentSection(
        _ section: Section,
        unitPosition: Int,
        direction: UnitNavigationDirection
    ) -> Promise<Unit?> {
        let unitID: Unit.IdType? = {
            switch direction {
            case .next:
                return section.unitsArray[safe: unitPosition + 1]
            case .previous:
                return section.unitsArray[safe: unitPosition - 1]
            }
        }()

        guard let targetUnitID = unitID else {
            return Promise.value(nil)
        }

        return self.getUnitFromCacheOrNetwork(id: targetUnitID)
    }

    private func findUnitInAnotherSections(
        courseID: Course.IdType,
        sectionPosition: Int,
        direction: UnitNavigationDirection
    ) -> Promise<Unit?> {
        return self.getSlicedSections(
            courseID: courseID,
            sectionPosition: sectionPosition,
            direction: direction
        ).then { sections -> Promise<Section?> in
            let sections = direction == .previous ? sections.reversed() : sections
            for section in sections where section.isReachable && !section.isExam && !section.unitsArray.isEmpty {
                return Promise.value(section)
            }

            return Promise.value(nil)
        }.then { targetSection -> Promise<Unit?> in
            guard let section = targetSection else {
                return Promise.value(nil)
            }

            guard let targetUnitID = direction == .previous
                ? section.unitsArray.last
                : section.unitsArray.first else {
                return Promise.value(nil)
            }

            // Load all units to make next findUnitInCurrentSection calls faster
            let allUnitsFromCacheOrNetwork = section.unitsArray.map { unitID in
                self.getUnitFromCacheOrNetwork(id: unitID)
            }

            return Promise { seal in
                when(fulfilled: allUnitsFromCacheOrNetwork).done { units in
                    let targetUnit = units.compactMap { $0 }
                        .first { $0.id == targetUnitID }
                    seal.fulfill(targetUnit)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }

    /// Return array of sections after or before section with given position
    private func getSlicedSections(
        courseID: Course.IdType,
        sectionPosition: Int,
        direction: UnitNavigationDirection
    ) -> Promise<[Section]> {
        return Promise { seal in
            self.getCourseFromCacheOrNetwork(id: courseID).then { course -> Promise<[Section]> in
                guard let course = course else {
                    throw Error.unknownCourse
                }

                let sectionIDs: [Section.IdType] = {
                    switch direction {
                    case .next:
                        return sectionPosition == course.sectionsArray.count - 1
                            ? []
                            : Array(course.sectionsArray[(sectionPosition + 1)...])
                    case .previous:
                        return sectionPosition == 0
                            ? []
                            : Array(course.sectionsArray[...(sectionPosition - 1)])
                    }
                }()

                return self.sectionsNetworkService.fetch(ids: sectionIDs)
            }.done { sections in
                seal.fulfill(sections)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    // MARK: Helpers
    // Remove after network layer & services refactoring

    private func getUnitFromCacheOrNetwork(id: Unit.IdType) -> Promise<Unit?> {
        return self.unitsPersistenceService.fetch(id: id).then { unit -> Promise<Unit?> in
            if let unit = unit {
                return Promise.value(unit)
            } else {
                return self.unitsNetworkService.fetch(id: id)
            }
        }
    }

    private func getCourseFromCacheOrNetwork(id: Course.IdType) -> Promise<Course?> {
        return self.coursesPersistenceService.fetch(id: id).then { course -> Promise<Course?> in
            if let course = course {
                return Promise.value(course)
            } else {
                return self.coursesNetworkService.fetch(id: id)
            }
        }
    }

    private func getSectionFromCacheOrNetwork(id: Section.IdType) -> Promise<Section?> {
        return self.sectionsPersistenceService.fetch(id: id).then { section -> Promise<Section?> in
            if let section = section {
                return Promise.value(section)
            } else {
                return self.sectionsNetworkService.fetch(id: id)
            }
        }
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case unknownCourse
    }
}
