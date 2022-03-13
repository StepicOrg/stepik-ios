import UIKit

protocol CertificatesListViewControllerProtocol: AnyObject {
    func displayCertificates(viewModel: CertificatesList.CertificatesLoad.ViewModel)
    func displayNextCertificates(viewModel: CertificatesList.NextCertificatesLoad.ViewModel)
}

final class CertificatesListViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: CertificatesListInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()
    var certificatesListView: CertificatesListView? { self.view as? CertificatesListView }

    private var state: CertificatesList.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    init(
        interactor: CertificatesListInteractorProtocol,
        initialState: CertificatesList.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Certificates", comment: "")

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.state = .loading
                    strongSelf.interactor.doCertificatesLoad(request: .init())
                }
            ),
            for: .connectionError
        )

        self.updateState()
        self.interactor.doCertificatesLoad(request: .init())
    }

    // MARK: Private API

    private func updateState() {
        switch self.state {
        case .result(let viewModel):
            self.isPlaceholderShown = false
            //self.certificateDetailView?.hideLoading()
            //self.certificateDetailView?.configure(viewModel: viewModel)
            print(viewModel)
        case .loading:
            self.isPlaceholderShown = false
            //self.certificateDetailView?.showLoading()
        case .error:
            //self.certificateDetailView?.hideLoading()
            self.showPlaceholder(for: .connectionError)
        }
    }
}

// MARK: - CertificatesListViewController: CertificatesListViewControllerProtocol -

extension CertificatesListViewController: CertificatesListViewControllerProtocol {
    func displayCertificates(viewModel: CertificatesList.CertificatesLoad.ViewModel) {
        self.state = viewModel.state
    }

    func displayNextCertificates(viewModel: CertificatesList.NextCertificatesLoad.ViewModel) {}
}
