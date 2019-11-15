import Foundation
import PromiseKit

protocol DownloadsInteractorProtocol {
    func doDownloadsFetch(request: Downloads.DownloadsLoad.Request)
}

// MARK: - DownloadsInteractor: DownloadsInteractorProtocol -

final class DownloadsInteractor: DownloadsInteractorProtocol {
    private let presenter: DownloadsPresenterProtocol
    private let provider: DownloadsProviderProtocol

    init(
        presenter: DownloadsPresenterProtocol,
        provider: DownloadsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    // MARK: - DownloadsInteractorProtocol

    func doDownloadsFetch(request: Downloads.DownloadsLoad.Request) {
        self.presenter.presentDownloads(response: .init(data: self.makeDownloadsData()))
    }

    // MARK: - Private API

    private func makeDownloadsData() -> Downloads.DownloadsData {
        return .init(downloadedItemsByCourse: [:])
    }

    // MARK: - Types

    enum Error: Swift.Error {
        case something
    }
}
