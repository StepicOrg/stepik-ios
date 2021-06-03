import Foundation
import PromiseKit

protocol WishlistWidgetInteractorProtocol {
    func doSomeAction(request: WishlistWidget.SomeAction.Request)
}

final class WishlistWidgetInteractor: WishlistWidgetInteractorProtocol {
    private let presenter: WishlistWidgetPresenterProtocol
    private let provider: WishlistWidgetProviderProtocol

    init(
        presenter: WishlistWidgetPresenterProtocol,
        provider: WishlistWidgetProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: WishlistWidget.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension WishlistWidgetInteractor: WishlistWidgetInputProtocol {}
