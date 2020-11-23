import UIKit

protocol CatalogBlocksViewControllerProtocol: AnyObject {
    func displayCatalogBlocks(viewModel: CatalogBlocks.CatalogBlocksLoad.ViewModel)
}

final class CatalogBlocksViewController: UIViewController {
    private let interactor: CatalogBlocksInteractorProtocol
    private var state: CatalogBlocks.ViewControllerState

    private var catalogBlocksView: CatalogBlocksView? { self.view as? CatalogBlocksView }

    init(
        interactor: CatalogBlocksInteractorProtocol,
        initialState: CatalogBlocks.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState(newState: self.state)
        self.interactor.doCatalogBlocksLoad(request: .init())
    }

    private func updateState(newState: CatalogBlocks.ViewControllerState) {
        self.state = newState

        switch self.state {
        case .loading:
            self.catalogBlocksView?.showLoading()
        case .result(let data):
            self.catalogBlocksView?.hideLoading()
            print(data)
        }
    }
}

extension CatalogBlocksViewController: CatalogBlocksViewControllerProtocol {
    func displayCatalogBlocks(viewModel: CatalogBlocks.CatalogBlocksLoad.ViewModel) {
        self.children.forEach { $0.removeFromParent() }
        self.catalogBlocksView?.removeAllBlocks()
        self.updateState(newState: viewModel.state)
    }
}
