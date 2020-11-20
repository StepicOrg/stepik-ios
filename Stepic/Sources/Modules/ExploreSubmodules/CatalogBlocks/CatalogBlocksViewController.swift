import UIKit

protocol CatalogBlocksViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: CatalogBlocks.SomeAction.ViewModel)
}

final class CatalogBlocksViewController: UIViewController {
    private let interactor: CatalogBlocksInteractorProtocol

    init(interactor: CatalogBlocksInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CatalogBlocksView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension CatalogBlocksViewController: CatalogBlocksViewControllerProtocol {
    func displaySomeActionResult(viewModel: CatalogBlocks.SomeAction.ViewModel) {}
}
