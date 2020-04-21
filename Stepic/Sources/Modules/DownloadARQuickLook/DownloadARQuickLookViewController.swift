import UIKit

protocol DownloadARQuickLookViewControllerProtocol: AnyObject {
    func displayDownloadProgressUpdate(viewModel: DownloadARQuickLook.DownloadProgressUpdate.ViewModel)
    func displayCancelDownloadResult(viewModel: DownloadARQuickLook.CancelDownload.ViewModel)
    func displayCompleteDownloadResult(viewModel: DownloadARQuickLook.CompleteDownload.ViewModel)
    func displayFailDownloadResult(viewModel: DownloadARQuickLook.FailDownload.ViewModel)
}

final class DownloadARQuickLookViewController: UIViewController {
    private let interactor: DownloadARQuickLookInteractorProtocol

    lazy var downloadARQuickLookView = self.view as? DownloadARQuickLookView

    init(interactor: DownloadARQuickLookInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = DownloadARQuickLookView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactor.doStartDownload(request: .init())
    }
}

extension DownloadARQuickLookViewController: DownloadARQuickLookViewControllerProtocol {
    func displayDownloadProgressUpdate(viewModel: DownloadARQuickLook.DownloadProgressUpdate.ViewModel) {
        self.downloadARQuickLookView?.progress = viewModel.progress
    }

    func displayCancelDownloadResult(viewModel: DownloadARQuickLook.CancelDownload.ViewModel) {
        self.dismiss(animated: true)
    }

    func displayCompleteDownloadResult(viewModel: DownloadARQuickLook.CompleteDownload.ViewModel) {
        self.dismiss(animated: true)
    }

    func displayFailDownloadResult(viewModel: DownloadARQuickLook.FailDownload.ViewModel) {
        self.dismiss(animated: true)
    }
}

extension DownloadARQuickLookViewController: DownloadARQuickLookViewDelegate {
    func downloadARQuickLookViewDidCancel(_ view: DownloadARQuickLookView) {
        self.interactor.doCancelDownload(request: .init())
    }
}
