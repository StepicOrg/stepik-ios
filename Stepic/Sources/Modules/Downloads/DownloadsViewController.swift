import UIKit

protocol DownloadsViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: Downloads.SomeAction.ViewModel)
}

final class DownloadsViewController: UIViewController {
    private let interactor: DownloadsInteractorProtocol

    init(interactor: DownloadsInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = DownloadsView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension DownloadsViewController: DownloadsViewControllerProtocol {
    func displaySomeActionResult(viewModel: Downloads.SomeAction.ViewModel) { }
}
