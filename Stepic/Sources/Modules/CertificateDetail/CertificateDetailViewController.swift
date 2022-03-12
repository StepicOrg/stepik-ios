import UIKit

protocol CertificateDetailViewControllerProtocol: AnyObject {
    func displayCertificate(viewModel: CertificateDetail.CertificateLoad.ViewModel)
}

final class CertificateDetailViewController: UIViewController {
    private let interactor: CertificateDetailInteractorProtocol

    var certificateDetailView: CertificateDetailView? { self.view as? CertificateDetailView }

    private lazy var shareBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(self.shareButtonClicked)
        )
        item.isEnabled = false
        return item
    }()

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

        self.navigationItem.rightBarButtonItem = self.shareBarButtonItem

        self.updateState()
        self.interactor.doCertificateLoad(request: .init())
    }

    // MARK: Private API

    private func updateState() {
        switch self.state {
        case .result(let viewModel):
            self.title = viewModel.isWithDistinction
                ? NSLocalizedString("CertificateDetailWithDistinctionTitle", comment: "")
                : NSLocalizedString("CertificateDetailTitle", comment: "")

            self.certificateDetailView?.configure(viewModel: viewModel)

            //self.isPlaceholderShown = false
            //self.showContent()
            self.shareBarButtonItem.isEnabled = true
        case .loading:
            //self.isPlaceholderShown = false
            //self.solutionView?.startLoading()
            self.shareBarButtonItem.isEnabled = false
        case .error:
            //self.showPlaceholder(for: .connectionError)
            self.shareBarButtonItem.isEnabled = false
        }
    }

    @objc
    private func shareButtonClicked() {
        guard case .result(let data) = self.state,
              let shareURL = data.shareURL else {
            return
        }

        DispatchQueue.global().async {
            let sharingViewController = SharingHelper.getSharingController(shareURL.absoluteString)
            DispatchQueue.main.async {
                sharingViewController.popoverPresentationController?.barButtonItem = self.shareBarButtonItem
                self.present(sharingViewController, animated: true)
            }
        }
    }
}

extension CertificateDetailViewController: CertificateDetailViewControllerProtocol {
    func displayCertificate(viewModel: CertificateDetail.CertificateLoad.ViewModel) {
        self.state = viewModel.state
    }
}
