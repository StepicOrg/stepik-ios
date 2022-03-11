import UIKit

protocol CertificateDetailViewControllerProtocol: AnyObject {
    func displaySomeActionResult(viewModel: CertificateDetail.SomeAction.ViewModel)
}

final class CertificateDetailViewController: UIViewController {
    private let interactor: CertificateDetailInteractorProtocol

    init(interactor: CertificateDetailInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CertificateDetailView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension CertificateDetailViewController: CertificateDetailViewControllerProtocol {
    func displaySomeActionResult(viewModel: CertificateDetail.SomeAction.ViewModel) {}
}
