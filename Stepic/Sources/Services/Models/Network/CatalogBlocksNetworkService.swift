import Foundation
import PromiseKit

protocol CatalogBlocksNetworkServiceProtocol: AnyObject {
    func fetch(ids: [CatalogBlock.IdType]) -> Promise<([CatalogBlock], Meta)>
    func fetch(language: ContentLanguage, page: Int) -> Promise<([CatalogBlock], Meta)>
}

extension CatalogBlocksNetworkServiceProtocol {
    func fetch(id: CatalogBlock.IdType) -> Promise<CatalogBlock?> {
        self.fetch(ids: [id]).then { catalogBlocks, _ -> Promise<CatalogBlock?> in
            .value(catalogBlocks.first)
        }
    }

    func fetch(language: ContentLanguage) -> Promise<([CatalogBlock], Meta)> {
        self.fetch(language: language, page: 1)
    }
}

final class CatalogBlocksNetworkService: CatalogBlocksNetworkServiceProtocol {
    private let catalogBlocksAPI: CatalogBlocksAPI

    init(catalogBlocksAPI: CatalogBlocksAPI) {
        self.catalogBlocksAPI = catalogBlocksAPI
    }

    func fetch(ids: [CatalogBlock.IdType]) -> Promise<([CatalogBlock], Meta)> {
        Promise { seal in
            self.catalogBlocksAPI.retrieve(ids: ids).done { catalogBlocks, meta in
                seal.fulfill((catalogBlocks, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(language: ContentLanguage, page: Int) -> Promise<([CatalogBlock], Meta)> {
        Promise { seal in
            self.catalogBlocksAPI.retrieve(language: language, page: page).done { catalogBlocks, meta in
                seal.fulfill((catalogBlocks, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
