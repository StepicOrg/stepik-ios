import UIKit

protocol CatalogBlocksViewControllerProtocol: AnyObject {
    func displayCatalogBlocks(viewModel: CatalogBlocks.CatalogBlocksLoad.ViewModel)
    func displayURL(viewModel: CatalogBlocks.URLPresentation.ViewModel)
}

final class CatalogBlocksViewController: UIViewController, ControllerWithStepikPlaceholder {
    var placeholderContainer = StepikPlaceholderControllerContainer()

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

        self.registerPlaceholders()
        self.updateState(newState: self.state)

        self.interactor.doCatalogBlocksLoad(request: .init())
    }

    private func updateState(newState: CatalogBlocks.ViewControllerState) {
        self.state = newState

        switch self.state {
        case .loading:
            self.catalogBlocksView?.showLoading()
            self.isPlaceholderShown = false
        case .error:
            self.catalogBlocksView?.hideLoading()
            self.showPlaceholder(for: .connectionError)
        case .result(let data):
            self.catalogBlocksView?.hideLoading()
            self.isPlaceholderShown = false

            for block in data {
                guard let module = CatalogBlockItemModuleFactory.makeCatalogBlockModule(
                    block: block,
                    interactor: self.interactor
                ) else {
                    continue
                }

                self.addChild(module.viewController)
                self.catalogBlocksView?.addBlockView(module.containerView)
            }
        }
    }

    private func registerPlaceholders() {
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .refreshCatalogBlocks,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.updateState(newState: .loading)
                    strongSelf.interactor.doCatalogBlocksLoad(request: .init())
                }
            ),
            for: .connectionError
        )
    }
}

// MARK: - CatalogBlocksViewController: CatalogBlocksViewControllerProtocol -

extension CatalogBlocksViewController: CatalogBlocksViewControllerProtocol {
    func displayCatalogBlocks(viewModel: CatalogBlocks.CatalogBlocksLoad.ViewModel) {
        self.children.forEach { $0.removeFromParent() }
        self.catalogBlocksView?.removeAllBlocks()
        self.updateState(newState: viewModel.state)
    }

    func displayURL(viewModel: CatalogBlocks.URLPresentation.ViewModel) {
        WebControllerManager.shared.presentWebControllerWithURL(
            viewModel.url,
            inController: self,
            withKey: .externalLink,
            allowsSafari: true,
            backButtonStyle: .done
        )
    }
}
