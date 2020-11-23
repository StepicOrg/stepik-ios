import Foundation
import PromiseKit

protocol CatalogBlocksProviderProtocol {
    func fetchCachedCatalogBlocks() -> Promise<[CatalogBlock]>
    func fetchRemoteCatalogBlocks() -> Promise<[CatalogBlock]>
}

final class CatalogBlocksProvider: CatalogBlocksProviderProtocol {
    private let contentLanguage: ContentLanguage
    private let catalogBlocksRepository: CatalogBlocksRepositoryProtocol

    init(
        contentLanguage: ContentLanguage,
        catalogBlocksRepository: CatalogBlocksRepositoryProtocol
    ) {
        self.contentLanguage = contentLanguage
        self.catalogBlocksRepository = catalogBlocksRepository
    }

    func fetchCachedCatalogBlocks() -> Promise<[CatalogBlock]> {
        Promise { seal in
            self.catalogBlocksRepository.fetch(
                language: self.contentLanguage,
                dataSourceType: .cache
            ).done { catalogBlocks, _ in
                let sortedCatalogBlocks = catalogBlocks.sorted { $0.position < $1.position }
                seal.fulfill(sortedCatalogBlocks)
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchRemoteCatalogBlocks() -> Promise<[CatalogBlock]> {
        Promise { seal in
            self.catalogBlocksRepository.fetch(
                language: self.contentLanguage,
                dataSourceType: .remote
            ).done { catalogBlocks, _ in
                let sortedCatalogBlocks = catalogBlocks.sorted { $0.position < $1.position }
                seal.fulfill(sortedCatalogBlocks)
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
