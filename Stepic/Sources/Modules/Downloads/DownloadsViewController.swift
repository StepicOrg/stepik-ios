import UIKit

protocol DownloadsViewControllerProtocol: AnyObject {
    func displayDownloads(viewModel: Downloads.DownloadsLoad.ViewModel)
    func displayDeleteDownloadResult(viewModel: Downloads.DownloadsLoad.ViewModel)
}

// MARK: - DownloadsViewController: UIViewController -

final class DownloadsViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: DownloadsInteractorProtocol
    private let analytics: Analytics

    lazy var downloadsView = self.view as? DownloadsView

    var placeholderContainer = StepikPlaceholderControllerContainer()

    private lazy var downloadsTableViewDataSource: DownloadsTableViewDataSource = {
        let dataSource = DownloadsTableViewDataSource()
        dataSource.delegate = self
        return dataSource
    }()

    // MARK: UIViewController life cycle

    init(interactor: DownloadsInteractorProtocol, analytics: Analytics) {
        self.interactor = interactor
        self.analytics = analytics
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
        self.setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.interactor.doDownloadsFetch(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.analytics.send(.downloadsScreenOpened)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.downloadsView?.setEditing(editing, animated: animated)
    }

    private func setup() {
        self.title = NSLocalizedString("DownloadsTitle", comment: "")
        self.registerPlaceholder(placeholder: StepikPlaceholder(.emptyDownloads), for: .empty)
    }
}

// MARK: - DownloadsViewController: DownloadsViewControllerProtocol -

extension DownloadsViewController: DownloadsViewControllerProtocol {
    func displayDownloads(viewModel: Downloads.DownloadsLoad.ViewModel) {
        self.updateDownloadsData(newData: viewModel.downloads)
    }

    func displayDeleteDownloadResult(viewModel: Downloads.DownloadsLoad.ViewModel) {
        self.updateDownloadsData(newData: viewModel.downloads)
    }

    // MARK: Private helpers

    private func updateDownloadsData(newData: [DownloadsItemViewModel]) {
        if newData.isEmpty {
            self.showPlaceholder(for: .empty)
            self.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.isPlaceholderShown = false
            self.navigationItem.rightBarButtonItem = self.editButtonItem
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

        let assembly = CourseInfoAssembly(
            courseID: selectedViewModel.id,
            initialTab: .syllabus,
            courseViewSource: .downloads
        )
        self.present(module: assembly.makeModule(), embedInNavigation: true, modalPresentationStyle: .fullScreen)
    }
}

// MARK: - DownloadsViewController: DownloadsTableViewDataSourceDelegate -

extension DownloadsViewController: DownloadsTableViewDataSourceDelegate {
    func downloadsTableViewDataSource(
        _ dataSource: DownloadsTableViewDataSource,
        didDelete viewModel: DownloadsItemViewModel,
        at indexPath: IndexPath
    ) {
        self.interactor.doDeleteDownload(request: .init(id: viewModel.id))
    }
}
