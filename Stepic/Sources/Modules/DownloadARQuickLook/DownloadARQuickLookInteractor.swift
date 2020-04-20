import Foundation
import PromiseKit

protocol DownloadARQuickLookInteractorProtocol {
    func doSomeAction(request: DownloadARQuickLook.SomeAction.Request)
}

final class DownloadARQuickLookInteractor: DownloadARQuickLookInteractorProtocol {
    weak var moduleOutput: DownloadARQuickLookOutputProtocol?

    private let presenter: DownloadARQuickLookPresenterProtocol
    private let provider: DownloadARQuickLookProviderProtocol

    init(
        presenter: DownloadARQuickLookPresenterProtocol,
        provider: DownloadARQuickLookProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: DownloadARQuickLook.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension DownloadARQuickLookInteractor: DownloadARQuickLookInputProtocol {}
