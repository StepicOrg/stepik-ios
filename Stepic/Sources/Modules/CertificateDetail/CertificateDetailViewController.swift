import UIKit

protocol CertificateDetailViewControllerProtocol: AnyObject {
    func displayCertificate(viewModel: CertificateDetail.CertificateLoad.ViewModel)
    func displayCertificatePDF(viewModel: CertificateDetail.CertificatePDFPresentation.ViewModel)
    func displayCourse(viewModel: CertificateDetail.CoursePresentation.ViewModel)
    func displayRecipient(viewModel: CertificateDetail.RecipientPresentation.ViewModel)
}

final class CertificateDetailViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: CertificateDetailInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()
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
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.shareBarButtonItem

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.state = .loading
                    strongSelf.interactor.doCertificateLoad(request: .init())
                }
            ),
            for: .connectionError
        )

        self.updateState()
        self.interactor.doCertificateLoad(request: .init())
    }

    // MARK: Private API

    private func updateState() {
        switch self.state {
        case .result(let viewModel):
            self.isPlaceholderShown = false
            self.shareBarButtonItem.isEnabled = true
            self.certificateDetailView?.hideLoading()

            self.title = viewModel.isWithDistinction
                ? NSLocalizedString("CertificateDetailWithDistinctionTitle", comment: "")
                : NSLocalizedString("CertificateDetailTitle", comment: "")

            self.certificateDetailView?.configure(viewModel: viewModel)
        case .loading:
            self.isPlaceholderShown = false
            self.shareBarButtonItem.isEnabled = false
            self.certificateDetailView?.showLoading()
        case .error:
            self.shareBarButtonItem.isEnabled = false
            self.certificateDetailView?.hideLoading()
            self.showPlaceholder(for: .connectionError)
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

// MARK: - CertificateDetailViewController: CertificateDetailViewControllerProtocol -

extension CertificateDetailViewController: CertificateDetailViewControllerProtocol {
    func displayCertificate(viewModel: CertificateDetail.CertificateLoad.ViewModel) {
        self.state = viewModel.state
    }

    func displayCertificatePDF(viewModel: CertificateDetail.CertificatePDFPresentation.ViewModel) {
        WebControllerManager.shared.presentWebControllerWithURL(
            viewModel.url,
            inController: self,
            withKey: .certificate,
            allowsSafari: true,
            backButtonStyle: .close
        )
    }

    func displayCourse(viewModel: CertificateDetail.CoursePresentation.ViewModel) {
        let assembly = CourseInfoAssembly(
            courseID: viewModel.courseID,
            courseViewSource: .certificate(id: viewModel.certificateID)
        )
        self.push(module: assembly.makeModule())
    }

    func displayRecipient(viewModel: CertificateDetail.RecipientPresentation.ViewModel) {
        let assembly = NewProfileAssembly(otherUserID: viewModel.userID)
        self.push(module: assembly.makeModule())
    }
}

// MARK: - CertificateDetailViewController: CertificateDetailViewDelegate -

extension CertificateDetailViewController: CertificateDetailViewDelegate {
    func certificateDetailViewDidClickPreview(_ view: CertificateDetailView) {
        self.interactor.doCertificatePDFPresentation(request: .init())
    }

    func certificateDetailViewDidClickCourse(_ view: CertificateDetailView) {
        self.interactor.doCoursePresentation(request: .init())
    }

    func certificateDetailViewDidClickRecipient(_ view: CertificateDetailView) {
        self.interactor.doRecipientPresentation(request: .init())
    }
}
