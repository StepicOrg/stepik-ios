import Foundation
import PromiseKit

protocol CatalogBlocksNetworkServiceProtocol: AnyObject {
    func fetch(language: ContentLanguage, page: Int) -> Promise<([CatalogBlock], Meta)>
}

extension CatalogBlocksNetworkServiceProtocol {
    func fetch(language: ContentLanguage) -> Promise<([CatalogBlock], Meta)> {
        self.fetch(language: language, page: 1)
    }
}

final class CatalogBlocksNetworkService: CatalogBlocksNetworkServiceProtocol {
    private let catalogBlocksAPI: CatalogBlocksAPI

    init(catalogBlocksAPI: CatalogBlocksAPI) {
        self.catalogBlocksAPI = catalogBlocksAPI
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
