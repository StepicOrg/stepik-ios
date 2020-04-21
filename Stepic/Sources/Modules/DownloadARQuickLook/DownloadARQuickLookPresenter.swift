import UIKit

protocol DownloadARQuickLookPresenterProtocol {
    func presentDownloadProgressUpdate(response: DownloadARQuickLook.DownloadProgressUpdate.Response)
}

final class DownloadARQuickLookPresenter: DownloadARQuickLookPresenterProtocol {
    weak var viewController: DownloadARQuickLookViewControllerProtocol?

    func presentDownloadProgressUpdate(response: DownloadARQuickLook.DownloadProgressUpdate.Response) {
        self.viewController?.displayDownloadProgressUpdate(viewModel: .init(progress: response.progress))
    }
}
