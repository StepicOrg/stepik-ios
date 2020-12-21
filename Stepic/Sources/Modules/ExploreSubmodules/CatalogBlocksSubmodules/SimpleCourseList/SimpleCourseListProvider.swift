import Foundation
import PromiseKit

protocol SimpleCourseListProviderProtocol {
    func fetchCachedCatalogBlock(id: CatalogBlock.IdType) -> Promise<CatalogBlock?>
    func fetchRemoteCatalogBlock(id: CatalogBlock.IdType) -> Promise<CatalogBlock?>

    func fetchCachedCourseLists(ids: [CourseListModel.IdType]) -> Guarantee<[CourseListModel]>
    func fetchRemoteCourseLists(ids: [CourseListModel.IdType]) -> Promise<[CourseListModel]>
    func fetchCourseLists(ids: [CourseListModel.IdType]) -> Promise<FetchResult<[CourseListModel]>>
}

final class SimpleCourseListProvider: SimpleCourseListProviderProtocol {
    private let catalogBlocksRepository: CatalogBlocksRepositoryProtocol
    private let courseListsPersistenceService: CourseListsPersistenceServiceProtocol
    private let courseListsNetworkService: CourseListsNetworkServiceProtocol

    init(
        catalogBlocksRepository: CatalogBlocksRepositoryProtocol,
        courseListsPersistenceService: CourseListsPersistenceServiceProtocol,
        courseListsNetworkService: CourseListsNetworkServiceProtocol
    ) {
        self.catalogBlocksRepository = catalogBlocksRepository
        self.courseListsPersistenceService = courseListsPersistenceService
        self.courseListsNetworkService = courseListsNetworkService
    }

    func fetchCachedCatalogBlock(id: CatalogBlock.IdType) -> Promise<CatalogBlock?> {
        Promise { seal in
            self.catalogBlocksRepository.fetch(ids: [id], dataSourceType: .cache).done { catalogBlocks, _ in
                seal.fulfill(catalogBlocks.first)
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchRemoteCatalogBlock(id: CatalogBlock.IdType) -> Promise<CatalogBlock?> {
        Promise { seal in
            self.catalogBlocksRepository.fetch(ids: [id], dataSourceType: .remote).done { catalogBlocks, _ in
                seal.fulfill(catalogBlocks.first)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchCachedCourseLists(ids: [CourseListModel.IdType]) -> Guarantee<[CourseListModel]> {
        self.courseListsPersistenceService.fetch(ids: ids).then { courseLists in
            let sortedCourseLists = courseLists.reordered(order: ids, transform: { $0.id })
            return .value(sortedCourseLists)
        }
    }

    func fetchRemoteCourseLists(ids: [CourseListModel.IdType]) -> Promise<[CourseListModel]> {
        Promise { seal in
            self.courseListsNetworkService.fetch(ids: ids).done { courseLists, _ in
                seal.fulfill(courseLists)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchCourseLists(ids: [CourseListModel.IdType]) -> Promise<FetchResult<[CourseListModel]>> {
        let persistenceGuarantee = self.fetchCachedCourseLists(ids: ids)
        let networkGuarantee = Guarantee(self.fetchRemoteCourseLists(ids: ids), fallback: nil)

        return Promise { seal in
            when(
                fulfilled: persistenceGuarantee,
                networkGuarantee
            ).then { cachedCourseLists, remoteCourseListsOrNil -> Promise<FetchResult<[CourseListModel]>> in
                if let remoteCourseLists = remoteCourseListsOrNil {
                    let result = FetchResult(value: remoteCourseLists, source: .remote)
                    return .value(result)
                } else {
                    let result = FetchResult(value: cachedCourseLists, source: .cache)
                    return .value(result)
                }
            }.done { result in
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
        case fetchFailed
    }
}
