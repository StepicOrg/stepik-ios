import Foundation
import PromiseKit

protocol DownloadARQuickLookInteractorProtocol {
    func doSomeAction(request: DownloadARQuickLook.SomeAction.Request)
}

final class DownloadARQuickLookInteractor: DownloadARQuickLookInteractorProtocol {
    weak var moduleOutput: DownloadARQuickLookOutputProtocol?

    private let url: URL
    private let presenter: DownloadARQuickLookPresenterProtocol

    init(
        url: URL,
        presenter: DownloadARQuickLookPresenterProtocol
    ) {
        self.url = url
        self.presenter = presenter
    }

    func doSomeAction(request: DownloadARQuickLook.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}
