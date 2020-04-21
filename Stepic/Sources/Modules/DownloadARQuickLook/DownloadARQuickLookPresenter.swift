import UIKit

protocol DownloadARQuickLookPresenterProtocol {
    func presentDownloadProgressUpdate(response: DownloadARQuickLook.DownloadProgressUpdate.Response)
    func presentCancelDownloadResult(response: DownloadARQuickLook.CancelDownload.Response)
    func presentCompleteDownloadResult(response: DownloadARQuickLook.CompleteDownload.Response)
    func presentFailDownloadResult(response: DownloadARQuickLook.FailDownload.Response)
}

final class DownloadARQuickLookPresenter: DownloadARQuickLookPresenterProtocol {
    weak var viewController: DownloadARQuickLookViewControllerProtocol?

    func presentDownloadProgressUpdate(response: DownloadARQuickLook.DownloadProgressUpdate.Response) {
        self.viewController?.displayDownloadProgressUpdate(viewModel: .init(progress: response.progress))
    }

    func presentCancelDownloadResult(response: DownloadARQuickLook.CancelDownload.Response) {
        self.viewController?.displayCancelDownloadResult(viewModel: .init())
    }

    func presentCompleteDownloadResult(response: DownloadARQuickLook.CompleteDownload.Response) {
        self.viewController?.displayCompleteDownloadResult(viewModel: .init())
    }

    func presentFailDownloadResult(response: DownloadARQuickLook.FailDownload.Response) {
        self.viewController?.displayFailDownloadResult(viewModel: .init())
    }
}
