import Foundation
import PromiseKit

protocol LessonFinishedDemoPanModalProviderProtocol {
    func fetchCourse(id: Course.IdType) -> Promise<Course?>
    func fetchSection(id: Section.IdType) -> Promise<Section?>
}

final class LessonFinishedDemoPanModalProvider: LessonFinishedDemoPanModalProviderProtocol {
    private let sectionsPersistenceService: SectionsPersistenceServiceProtocol
    private let sectionsNetworkService: SectionsNetworkServiceProtocol

    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let coursesNetworkService: CoursesNetworkServiceProtocol

    init(
        sectionsPersistenceService: SectionsPersistenceServiceProtocol,
        sectionsNetworkService: SectionsNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol
    ) {
        self.sectionsPersistenceService = sectionsPersistenceService
        self.sectionsNetworkService = sectionsNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.coursesNetworkService = coursesNetworkService
    }

    func fetchSection(id: Section.IdType) -> Promise<Section?> {
        self.sectionsPersistenceService.fetch(id: id).then { cachedSectionOrNil -> Promise<Section?> in
            if let cachedSection = cachedSectionOrNil {
                return .value(cachedSection)
            } else {
                return self.sectionsNetworkService.fetch(id: id)
            }
        }
    }

    func fetchCourse(id: Course.IdType) -> Promise<Course?> {
        self.coursesPersistenceService.fetch(id: id).then { cachedCourseOrNil -> Promise<Course?> in
            if let cachedCourse = cachedCourseOrNil {
                return .value(cachedCourse)
            } else {
                return self.coursesNetworkService.fetch(id: id)
            }
        }
    }
}
