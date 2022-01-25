import Foundation
import PromiseKit

protocol LessonFinishedDemoPanModalProviderProtocol {
    func fetchCourse(id: Course.IdType) -> Promise<Course?>
    func fetchSection(id: Section.IdType) -> Promise<Section?>

    func fetchMobileTier(courseID: Course.IdType, promoCodeName: String?) -> Promise<MobileTierPlainObject?>
}

final class LessonFinishedDemoPanModalProvider: LessonFinishedDemoPanModalProviderProtocol {
    private let sectionsPersistenceService: SectionsPersistenceServiceProtocol
    private let sectionsNetworkService: SectionsNetworkServiceProtocol

    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let coursesNetworkService: CoursesNetworkServiceProtocol

    private let mobileTiersRepository: MobileTiersRepositoryProtocol

    init(
        sectionsPersistenceService: SectionsPersistenceServiceProtocol,
        sectionsNetworkService: SectionsNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        mobileTiersRepository: MobileTiersRepositoryProtocol
    ) {
        self.sectionsPersistenceService = sectionsPersistenceService
        self.sectionsNetworkService = sectionsNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.coursesNetworkService = coursesNetworkService
        self.mobileTiersRepository = mobileTiersRepository
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

    func fetchMobileTier(courseID: Course.IdType, promoCodeName: String?) -> Promise<MobileTierPlainObject?> {
        self.mobileTiersRepository.fetch(courseID: courseID, promoCodeName: promoCodeName, fetchPolicy: .cacheFirst)
    }
}
