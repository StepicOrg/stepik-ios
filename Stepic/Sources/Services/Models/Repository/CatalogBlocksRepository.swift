import Foundation
import PromiseKit

protocol CatalogBlocksRepositoryProtocol: AnyObject {
    func fetch(ids: [CatalogBlock.IdType], dataSourceType: DataSourceType) -> Promise<([CatalogBlock], Meta)>
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

    func fetch(ids: [CatalogBlock.IdType], dataSourceType: DataSourceType) -> Promise<([CatalogBlock], Meta)> {
        switch dataSourceType {
        case .cache:
            return self.catalogBlocksPersistenceService
                .fetch(ids: ids)
                .mapValues(\.plainObject)
                .map { ($0, Meta.oneAndOnlyPage) }
        case .remote:
            return self.catalogBlocksNetworkService
                .fetch(ids: ids)
                .then { remoteCatalogBlocks, meta in
                    self.catalogBlocksPersistenceService
                        .save(catalogBlocks: remoteCatalogBlocks)
                        .map { (remoteCatalogBlocks, meta) }
                }
        }
    }

    func fetch(language: ContentLanguage, dataSourceType: DataSourceType) -> Promise<([CatalogBlock], Meta)> {
        switch dataSourceType {
        case .cache:
            return self.catalogBlocksPersistenceService
                .fetch(language: language)
                .mapValues(\.plainObject)
                .map { ($0, Meta.oneAndOnlyPage) }
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
