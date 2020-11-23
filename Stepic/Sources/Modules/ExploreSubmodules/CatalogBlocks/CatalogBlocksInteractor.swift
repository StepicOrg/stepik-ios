import Foundation
import PromiseKit

protocol CatalogBlocksInteractorProtocol {
    func doCatalogBlocksLoad(request: CatalogBlocks.CatalogBlocksLoad.Request)
}

final class CatalogBlocksInteractor: CatalogBlocksInteractorProtocol {
    weak var moduleOutput: CatalogBlocksOutputProtocol?

    private let presenter: CatalogBlocksPresenterProtocol
    private let provider: CatalogBlocksProviderProtocol

    init(
        presenter: CatalogBlocksPresenterProtocol,
        provider: CatalogBlocksProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doCatalogBlocksLoad(request: CatalogBlocks.CatalogBlocksLoad.Request) {
        self.provider.fetchCachedCatalogBlocks().then { cachedCatalogBlocks -> Promise<[CatalogBlock]> in
            self.presenter.presentCatalogBlocks(response: .init(result: .success(cachedCatalogBlocks)))
            return self.provider.fetchRemoteCatalogBlocks()
        }.done { remoteCatalogBlocks in
            self.presenter.presentCatalogBlocks(response: .init(result: .success(remoteCatalogBlocks)))
        }.catch { _ in }
    }
}
