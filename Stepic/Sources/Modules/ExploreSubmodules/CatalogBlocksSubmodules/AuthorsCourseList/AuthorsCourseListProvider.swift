import Foundation
import PromiseKit

protocol AuthorsCourseListProviderProtocol {
    func fetchCachedCatalogBlock(id: CatalogBlock.IdType) -> Promise<CatalogBlock?>
    func fetchRemoteCatalogBlock(id: CatalogBlock.IdType) -> Promise<CatalogBlock?>

    func fetchCachedUsers(ids: [User.IdType]) -> Guarantee<[User]>
    func fetchRemoteUsers(ids: [User.IdType]) -> Promise<[User]>
    func fetchUsers(ids: [User.IdType]) -> Promise<FetchResult<[User]>>
}

final class AuthorsCourseListProvider: AuthorsCourseListProviderProtocol {
    private let catalogBlocksRepository: CatalogBlocksRepositoryProtocol
    private let usersPersistenceService: UsersPersistenceServiceProtocol
    private let usersNetworkService: UsersNetworkServiceProtocol

    init(
        catalogBlocksRepository: CatalogBlocksRepositoryProtocol,
        usersPersistenceService: UsersPersistenceServiceProtocol,
        usersNetworkService: UsersNetworkServiceProtocol
    ) {
        self.catalogBlocksRepository = catalogBlocksRepository
        self.usersPersistenceService = usersPersistenceService
        self.usersNetworkService = usersNetworkService
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

    func fetchCachedUsers(ids: [User.IdType]) -> Guarantee<[User]> {
        self.usersPersistenceService.fetch(ids: ids).then { users in
            let sortedUsers = users.reordered(order: ids, transform: { $0.id })
            return .value(sortedUsers)
        }
    }

    func fetchRemoteUsers(ids: [User.IdType]) -> Promise<[User]> {
        Promise { seal in
            self.usersNetworkService.fetch(ids: ids).done { users in
                let sortedUsers = users.reordered(order: ids, transform: { $0.id })
                seal.fulfill(sortedUsers)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchUsers(ids: [User.IdType]) -> Promise<FetchResult<[User]>> {
        let persistenceGuarantee = self.fetchCachedUsers(ids: ids)
        let networkGuarantee = Guarantee(self.fetchRemoteUsers(ids: ids), fallback: nil)

        return Promise { seal in
            when(
                fulfilled: persistenceGuarantee,
                networkGuarantee
            ).then { cachedUsers, remoteUsersOrNil -> Promise<FetchResult<[User]>> in
                if let remoteUsers = remoteUsersOrNil {
                    let result = FetchResult(value: remoteUsers, source: .remote)
                    return .value(result)
                } else {
                    let result = FetchResult(value: cachedUsers, source: .cache)
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
