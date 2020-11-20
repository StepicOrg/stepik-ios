import Foundation
import PromiseKit

protocol CatalogBlocksInteractorProtocol {
    func doSomeAction(request: CatalogBlocks.SomeAction.Request)
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

    func doSomeAction(request: CatalogBlocks.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension CatalogBlocksInteractor: CatalogBlocksInputProtocol {}
