import Foundation
import PromiseKit

protocol StepikAcademyCourseListProviderProtocol {
    func fetchCachedCatalogBlock(id: CatalogBlock.IdType) -> Promise<CatalogBlock?>
    func fetchRemoteCatalogBlock(id: CatalogBlock.IdType) -> Promise<CatalogBlock?>
}

final class StepikAcademyCourseListProvider: StepikAcademyCourseListProviderProtocol {
    private let catalogBlocksRepository: CatalogBlocksRepositoryProtocol

    init(catalogBlocksRepository: CatalogBlocksRepositoryProtocol) {
        self.catalogBlocksRepository = catalogBlocksRepository
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

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
    }
}
