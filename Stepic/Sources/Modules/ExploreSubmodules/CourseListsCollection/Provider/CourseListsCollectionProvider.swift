import Foundation
import PromiseKit

protocol CourseListsCollectionProviderProtocol: class {
    func fetchCachedCourseLists() -> Promise<[CourseListModel]>
    func fetchRemoteCourseLists() -> Promise<[CourseListModel]>
}

final class CourseListsCollectionProvider: CourseListsCollectionProviderProtocol {
    private let language: ContentLanguage
    private let collectionsPersistenceService: CourseListsCollectionPersistenceServiceProtocol
    private let collectionsNetworkService: CourseListsCollectionNetworkServiceProtocol

    init(
        language: ContentLanguage,
        courseListsCollectionsPersistenceService: CourseListsCollectionPersistenceServiceProtocol,
        collectionsNetworkService: CourseListsCollectionNetworkServiceProtocol
    ) {
        self.language = language
        self.collectionsPersistenceService = courseListsCollectionsPersistenceService
        self.collectionsNetworkService = collectionsNetworkService
    }

    func fetchCachedCourseLists() -> Promise<[CourseListModel]> {
        return Promise { seal in
            self.collectionsPersistenceService.fetch(
                forLanguage: self.language
            ).done { courseLists in
                let courseLists = courseLists.sorted { $0.position < $1.position }
                seal.fulfill(courseLists)
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchRemoteCourseLists() -> Promise<[CourseListModel]> {
        return Promise { seal in
            self.collectionsNetworkService.fetch(
                language: self.language,
                page: 1
            ).done { courseLists, _ in
                let courseLists = courseLists.sorted { $0.position < $1.position }

                self.collectionsPersistenceService.update(
                    courseLists: courseLists,
                    forLanguage: self.language
                )
                seal.fulfill(courseLists)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
    }
}
