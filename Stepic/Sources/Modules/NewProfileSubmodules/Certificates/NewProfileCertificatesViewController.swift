import UIKit

protocol NewProfileCertificatesViewControllerProtocol: AnyObject {
    func displayCertificates(viewModel: NewProfileCertificates.CertificatesLoad.ViewModel)
}

final class NewProfileCertificatesViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: NewProfileCertificatesInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()
    var newProfileCertificatesView: NewProfileCertificatesView? { self.view as? NewProfileCertificatesView }

    // swiftlint:disable weak_delegate
    private let collectionViewDelegate = NewProfileCertificatesCollectionViewDelegate()
    private let collectionViewDataSource = NewProfileCertificatesCollectionViewDataSource()
    // swiftlint:enable weak_delegate

    private var state: NewProfileCertificates.ViewControllerState

    init(
        interactor: NewProfileCertificatesInteractorProtocol,
        initialState: NewProfileCertificates.ViewControllerState = .loading
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
        let view = NewProfileCertificatesView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .tryAgain,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.updateState(newState: .loading)
                    strongSelf.interactor.doCertificatesLoad(request: .init())
                }
            ),
            for: .connectionError
        )

        self.updateState(newState: self.state)
    }

    private func updateState(newState: NewProfileCertificates.ViewControllerState) {
        defer {
            self.state = newState
        }

        if case .loading = newState {
            self.isPlaceholderShown = false
            self.newProfileCertificatesView?.showLoading()
            return
        }

        if case .loading = self.state {
            self.isPlaceholderShown = false
            self.newProfileCertificatesView?.hideLoading()
        }

        switch newState {
        case .result(let viewModel):
            self.collectionViewDelegate.viewModels = viewModel.certificates
            self.collectionViewDataSource.viewModels = viewModel.certificates
            self.newProfileCertificatesView?.updateCollectionViewData(
                delegate: self.collectionViewDelegate,
                dataSource: self.collectionViewDataSource
            )
        case .error:
            self.showPlaceholder(for: .connectionError)
        case .loading:
            break
        }
    }
}

extension NewProfileCertificatesViewController: NewProfileCertificatesViewControllerProtocol {
    func displayCertificates(viewModel: NewProfileCertificates.CertificatesLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}
