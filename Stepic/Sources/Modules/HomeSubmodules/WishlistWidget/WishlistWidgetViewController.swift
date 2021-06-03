import UIKit

protocol WishlistWidgetViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: WishlistWidget.SomeAction.ViewModel)
}

final class WishlistWidgetViewController: UIViewController {
    private let interactor: WishlistWidgetInteractorProtocol

    init(interactor: WishlistWidgetInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = WishlistWidgetView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension WishlistWidgetViewController: WishlistWidgetViewControllerProtocol {
    func displaySomeActionResult(viewModel: WishlistWidget.SomeAction.ViewModel) {}
}
