import UIKit

protocol DownloadARQuickLookViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: DownloadARQuickLook.SomeAction.ViewModel)
}

final class DownloadARQuickLookViewController: UIViewController {
    private let interactor: DownloadARQuickLookInteractorProtocol

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
}

extension DownloadARQuickLookViewController: DownloadARQuickLookViewControllerProtocol {
    func displaySomeActionResult(viewModel: DownloadARQuickLook.SomeAction.ViewModel) {}
}

extension DownloadARQuickLookViewController: DownloadARQuickLookViewDelegate {
    func downloadARQuickLookViewDidCancel(_ view: DownloadARQuickLookView) {
        self.dismiss(animated: true, completion: nil)
    }
}
