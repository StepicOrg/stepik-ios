import UIKit

protocol NewProfileCertificatesViewControllerProtocol: AnyObject {
    func displayCertificates(viewModel: NewProfileCertificates.CertificatesLoad.ViewModel)
}

final class NewProfileCertificatesViewController: UIViewController {
    private let interactor: NewProfileCertificatesInteractorProtocol

    init(interactor: NewProfileCertificatesInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileCertificatesView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewProfileCertificatesViewController: NewProfileCertificatesViewControllerProtocol {
    func displayCertificates(viewModel: NewProfileCertificates.CertificatesLoad.ViewModel) {}
}
