import UIKit

protocol DownloadsViewControllerProtocol: class {
    func displayDownloads(viewModel: Downloads.DownloadsLoad.ViewModel)
}

// MARK: - DownloadsViewController: UIViewController -

final class DownloadsViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: DownloadsInteractorProtocol

    lazy var downloadsView = self.view as? DownloadsView

    var placeholderContainer = StepikPlaceholderControllerContainer()

    private lazy var downloadsTableViewDataSource = DownloadsTableViewDataSource()

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
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("DownloadsTitle", comment: "")
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

        self.downloadsTableViewDataSource.update(viewModels: newData)
        self.downloadsView?.updateTableViewData(dataSource: self.downloadsTableViewDataSource)
    }
}

// MARK: - DownloadsViewController: DownloadsViewDelegate -

extension DownloadsViewController: DownloadsViewDelegate {
    func downloadsView(_ downloadsView: DownloadsView, didSelectCell cell: UITableViewCell, at indexPath: IndexPath) {
        guard let selectedViewModel = self.downloadsTableViewDataSource.viewModels[safe: indexPath.row] else {
            return
        }

        let assembly = CourseInfoAssembly(courseID: selectedViewModel.id, initialTab: .syllabus)
        self.push(module: assembly.makeModule())
    }
}
