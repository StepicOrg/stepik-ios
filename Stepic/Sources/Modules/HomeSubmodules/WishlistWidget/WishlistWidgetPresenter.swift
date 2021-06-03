import UIKit

protocol WishlistWidgetPresenterProtocol {
    func presentSomeActionResult(response: WishlistWidget.SomeAction.Response)
}

final class WishlistWidgetPresenter: WishlistWidgetPresenterProtocol {
    weak var viewController: WishlistWidgetViewControllerProtocol?

    func presentSomeActionResult(response: WishlistWidget.SomeAction.Response) {}
}
