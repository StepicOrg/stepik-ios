import UIKit

protocol CertificatesListViewControllerProtocol: AnyObject {
    func displayCertificates(viewModel: CertificatesList.CertificatesLoad.ViewModel)
    func displayNextCertificates(viewModel: CertificatesList.NextCertificatesLoad.ViewModel)
}

final class CertificatesListViewController: UIViewController {
    private let interactor: CertificatesListInteractorProtocol

    init(interactor: CertificatesListInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CertificatesListView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension CertificatesListViewController: CertificatesListViewControllerProtocol {
    func displayCertificates(viewModel: CertificatesList.CertificatesLoad.ViewModel) {}

    func displayNextCertificates(viewModel: CertificatesList.NextCertificatesLoad.ViewModel) {}
}
