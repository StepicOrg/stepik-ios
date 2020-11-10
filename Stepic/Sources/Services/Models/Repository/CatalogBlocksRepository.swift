import Foundation
import PromiseKit

protocol CatalogBlocksRepositoryProtocol: AnyObject {
    func fetch(language: ContentLanguage, dataSourceType: DataSourceType) -> Promise<([CatalogBlock], Meta)>
}

final class CatalogBlocksRepository: CatalogBlocksRepositoryProtocol {
    private let catalogBlocksNetworkService: CatalogBlocksNetworkServiceProtocol
    private let catalogBlocksPersistenceService: CatalogBlocksPersistenceServiceProtocol

    init(
        catalogBlocksNetworkService: CatalogBlocksNetworkServiceProtocol,
        catalogBlocksPersistenceService: CatalogBlocksPersistenceServiceProtocol
    ) {
        self.catalogBlocksNetworkService = catalogBlocksNetworkService
        self.catalogBlocksPersistenceService = catalogBlocksPersistenceService
    }

    func fetch(language: ContentLanguage, dataSourceType: DataSourceType) -> Promise<([CatalogBlock], Meta)> {
        switch dataSourceType {
        case .cache:
            return Promise { seal in
                self.catalogBlocksPersistenceService
                    .fetch(language: language)
                    .done { cachedCatalogBlockEntities in
                        let catalogBlocks = cachedCatalogBlockEntities.map(\.plainObject)
                        seal.fulfill((catalogBlocks, Meta.oneAndOnlyPage))
                    }
            }
        case .remote:
            return self.catalogBlocksNetworkService
                .fetch(language: language)
                .then { remoteCatalogBlocks, meta in
                    self.catalogBlocksPersistenceService
                        .save(catalogBlocks: remoteCatalogBlocks)
                        .map { (remoteCatalogBlocks, meta) }
                }
        }
    }
}
