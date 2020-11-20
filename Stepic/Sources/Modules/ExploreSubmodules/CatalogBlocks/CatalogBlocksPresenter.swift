import UIKit

protocol CatalogBlocksPresenterProtocol {
    func presentSomeActionResult(response: CatalogBlocks.SomeAction.Response)
}

final class CatalogBlocksPresenter: CatalogBlocksPresenterProtocol {
    weak var viewController: CatalogBlocksViewControllerProtocol?

    func presentSomeActionResult(response: CatalogBlocks.SomeAction.Response) {}
}
