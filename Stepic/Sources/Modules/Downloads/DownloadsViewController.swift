import UIKit

protocol DownloadsViewControllerProtocol: class {
    func displayDownloads(viewModel: Downloads.DownloadsLoad.ViewModel)
}

// MARK: - DownloadsViewController: UIViewController -

final class DownloadsViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: DownloadsInteractorProtocol

    lazy var downloadsView = self.view as? DownloadsView

    var placeholderContainer = StepikPlaceholderControllerContainer()

    // MARK: UIViewController life cycle

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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Downloads", comment: "")
        self.registerPlaceholders()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.interactor.doDownloadsFetch(request: .init())
    }

    // MARK: - Private API

    private func registerPlaceholders() {
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .emptyDownloads,
                action: { TabBarRouter(tab: .catalog).route() }
            ),
            for: .empty
        )
    }
}

// MARK: - DownloadsViewController: DownloadsViewControllerProtocol -

extension DownloadsViewController: DownloadsViewControllerProtocol {
    func displayDownloads(viewModel: Downloads.DownloadsLoad.ViewModel) {
        self.updateDownloadsData(newData: viewModel.downloads)
    }

    private func updateDownloadsData(newData: [DownloadsItemViewModel]) {
        if newData.isEmpty {
            self.showPlaceholder(for: .empty)
        } else {
            self.isPlaceholderShown = false
        }

        // TODO: Update list view
    }
}
