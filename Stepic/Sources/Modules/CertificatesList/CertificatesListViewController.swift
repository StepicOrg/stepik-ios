import UIKit

protocol CertificatesListViewControllerProtocol: AnyObject {
    func displayCertificates(viewModel: CertificatesList.CertificatesLoad.ViewModel)
    func displayNextCertificates(viewModel: CertificatesList.NextCertificatesLoad.ViewModel)
    func displayCertificateDetail(viewModel: CertificatesList.CertificateDetailPresentation.ViewModel)
}

final class CertificatesListViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: CertificatesListInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()
    var certificatesListView: CertificatesListView? { self.view as? CertificatesListView }

    private lazy var tableViewAdapter = CertificatesListTableViewAdapter(delegate: self)

    private var state: CertificatesList.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    private var canTriggerPagination = false {
        didSet {
            self.tableViewAdapter.canTriggerPagination = self.canTriggerPagination
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
        case .loading:
            self.isPlaceholderShown = false
            self.certificatesListView?.showLoading()
        case .error:
            self.certificatesListView?.hideLoading()
            self.showPlaceholder(for: .connectionError)
        case .result(let viewModel):
            self.isPlaceholderShown = false
            self.certificatesListView?.hideLoading()

            self.tableViewAdapter.viewModels = viewModel.certificates
            self.certificatesListView?.updateTableViewData(delegate: self.tableViewAdapter)

            self.updatePagination(hasNextPage: viewModel.hasNextPage)
        }
    }

    private func updatePagination(hasNextPage: Bool) {
        self.canTriggerPagination = hasNextPage

        if hasNextPage {
            self.certificatesListView?.showPaginationView()
        } else {
            self.certificatesListView?.hidePaginationView()
        }
    }
}

// MARK: - CertificatesListViewController: CertificatesListViewControllerProtocol -

extension CertificatesListViewController: CertificatesListViewControllerProtocol {
    func displayCertificates(viewModel: CertificatesList.CertificatesLoad.ViewModel) {
        self.state = viewModel.state
    }

    func displayNextCertificates(viewModel: CertificatesList.NextCertificatesLoad.ViewModel) {
        switch (self.state, viewModel.state) {
        case (.result(let currentData), .result(let nextData)):
            let resultData = CertificatesList.CertificatesResult(
                certificates: currentData.certificates + nextData.certificates,
                hasNextPage: nextData.hasNextPage
            )
            self.state = .result(data: resultData)
        case (_, .error):
            self.updateState()
        default:
            break
        }
    }

    func displayCertificateDetail(viewModel: CertificatesList.CertificateDetailPresentation.ViewModel) {
        let assembly = CertificateDetailAssembly(
            certificateID: viewModel.certificateID,
            output: self.interactor as? CertificateDetailOutputProtocol
        )
        self.push(module: assembly.makeModule())
    }
}

// MARK: - CertificatesListViewController: CertificatesListTableViewAdapterDelegate -

extension CertificatesListViewController: CertificatesListTableViewAdapterDelegate {
    func certificatesListTableViewAdapter(
        _ adapter: CertificatesListTableViewAdapter,
        didSelectCertificate certificate: CertificatesListItemViewModel,
        at indexPath: IndexPath
    ) {
        self.interactor.doCertificateDetailPresentation(
            request: .init(viewModelUniqueIdentifier: certificate.uniqueIdentifier)
        )
    }

    func certificatesListTableViewAdapterDidRequestPagination(_ adapter: CertificatesListTableViewAdapter) {
        guard self.canTriggerPagination else {
            return
        }

        self.canTriggerPagination = false
        self.interactor.doNextCertificatesLoad(request: .init())
    }
}
