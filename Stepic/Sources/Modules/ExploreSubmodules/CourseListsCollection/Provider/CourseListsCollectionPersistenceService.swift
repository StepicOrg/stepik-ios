import Foundation
import PromiseKit

protocol CourseListsCollectionPersistenceServiceProtocol: class {
    func fetch(forLanguage language: ContentLanguage) -> Promise<[CourseListModel]>
    func update(courseLists: [CourseListModel], forLanguage language: ContentLanguage)
}

final class CourseListsCollectionPersistenceService: CourseListsCollectionPersistenceServiceProtocol {
    func fetch(forLanguage language: ContentLanguage) -> Promise<[CourseListModel]> {
        let ids = UserDefaults.standard.value(
            forKey: self.getKey(forLanguage: language)
        ) as? [CourseListModel.IdType] ?? []
        return Promise { seal in
            CourseListModel.recoverAsync(ids: ids).done { courseLists in
                let courseLists = Sorter.sort(courseLists, byIds: ids)
                seal.fulfill(courseLists)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func update(courseLists: [CourseListModel], forLanguage language: ContentLanguage) {
        let ids = courseLists.map { $0.id }
        UserDefaults.standard.setValue(ids, forKey: self.getKey(forLanguage: language))
    }

    private func getKey(forLanguage language: ContentLanguage) -> String {
        return "ListIds_\(language.languageString)"
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
