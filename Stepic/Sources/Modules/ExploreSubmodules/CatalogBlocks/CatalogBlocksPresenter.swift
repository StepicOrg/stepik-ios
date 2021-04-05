import UIKit

protocol CatalogBlocksPresenterProtocol {
    func presentCatalogBlocks(response: CatalogBlocks.CatalogBlocksLoad.Response)
    func presentURL(response: CatalogBlocks.URLPresentation.Response)
}

final class CatalogBlocksPresenter: CatalogBlocksPresenterProtocol {
    weak var viewController: CatalogBlocksViewControllerProtocol?

    func presentCatalogBlocks(response: CatalogBlocks.CatalogBlocksLoad.Response) {
        switch response.result {
        case .success(let result):
            self.viewController?.displayCatalogBlocks(viewModel: .init(state: .result(data: result)))
        case .failure:
            self.viewController?.displayCatalogBlocks(viewModel: .init(state: .error))
        }
    }

    func presentURL(response: CatalogBlocks.URLPresentation.Response) {
        self.viewController?.displayURL(viewModel: .init(url: response.url))
    }
}
