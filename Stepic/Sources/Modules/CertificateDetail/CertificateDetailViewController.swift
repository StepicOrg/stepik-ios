import UIKit

protocol CertificateDetailViewControllerProtocol: AnyObject {
    func displayCertificate(viewModel: CertificateDetail.CertificateLoad.ViewModel)
}

final class CertificateDetailViewController: UIViewController {
    private let interactor: CertificateDetailInteractorProtocol

    private var state: CertificateDetail.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    init(
        interactor: CertificateDetailInteractorProtocol,
        initialState: CertificateDetail.ViewControllerState = .loading
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
        let view = CertificateDetailView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateState()
    }

    // MARK: Private API

    private func updateState() {
        switch self.state {
        case .result:
            //self.isPlaceholderShown = false
            //self.showContent()
            break
        case .loading:
            //self.isPlaceholderShown = false
            //self.solutionView?.startLoading()
            break
        case .error:
            //self.showPlaceholder(for: .connectionError)
            break
        }
    }
}

extension CertificateDetailViewController: CertificateDetailViewControllerProtocol {
    func displayCertificate(viewModel: CertificateDetail.CertificateLoad.ViewModel) {
        self.state = viewModel.state
    }
}
