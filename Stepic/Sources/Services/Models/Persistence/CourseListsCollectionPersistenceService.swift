import Foundation
import PromiseKit

protocol CourseListsCollectionPersistenceServiceProtocol: AnyObject {
    func fetch(forLanguage language: ContentLanguage) -> Guarantee<[CourseListModel]>
    func update(courseLists: [CourseListModel], forLanguage language: ContentLanguage)
}

final class CourseListsCollectionPersistenceService: CourseListsCollectionPersistenceServiceProtocol {
    private let courseListsPersistenceService: CourseListsPersistenceServiceProtocol

    init(courseListsPersistenceService: CourseListsPersistenceServiceProtocol = CourseListsPersistenceService()) {
        self.courseListsPersistenceService = courseListsPersistenceService
    }

    func fetch(forLanguage language: ContentLanguage) -> Guarantee<[CourseListModel]> {
        let ids = UserDefaults.standard.value(
            forKey: self.getKey(forLanguage: language)
        ) as? [CourseListModel.IdType] ?? []

        return self.courseListsPersistenceService.fetch(ids: ids).then { courseLists in
            let sortedCourseLists = courseLists.reordered(order: ids, transform: { $0.id })
            return .value(sortedCourseLists)
        }
    }

    func update(courseLists: [CourseListModel], forLanguage language: ContentLanguage) {
        let ids = courseLists.map { $0.id }
        UserDefaults.standard.setValue(ids, forKey: self.getKey(forLanguage: language))
    }

    private func getKey(forLanguage language: ContentLanguage) -> String {
        "ListIds_\(language.languageString)"
    }
}
