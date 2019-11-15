import Foundation
import PromiseKit

protocol DownloadsInteractorProtocol {
    func doSomeAction(request: Downloads.SomeAction.Request)
}

final class DownloadsInteractor: DownloadsInteractorProtocol {
    weak var moduleOutput: DownloadsOutputProtocol?

    private let presenter: DownloadsPresenterProtocol
    private let provider: DownloadsProviderProtocol

    init(
        presenter: DownloadsPresenterProtocol,
        provider: DownloadsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: Downloads.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}

extension DownloadsInteractor: DownloadsInputProtocol { }