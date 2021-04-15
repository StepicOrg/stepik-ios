import SnapKit
import UIKit

protocol DebugMenuViewDelegate: SettingsTableViewDelegate {}

extension DebugMenuView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground
        let loadingIndicatorColor = UIColor.stepikLoadingIndicator
    }
}

final class DebugMenuView: UIView {
    let appearance: Appearance

    weak var delegate: DebugMenuViewDelegate? {
        didSet {
            self.tableView.delegate = self.delegate
        }
    }

    private lazy var tableView: SettingsTableView = {
        let tableView = SettingsTableView(appearance: .init(style: .stepikInsetGrouped))
        tableView.isRefreshControlEnabled = true
        return tableView
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .stepikWhiteLarge)
        loadingIndicatorView.color = self.appearance.loadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.stopAnimating()
        return loadingIndicatorView
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: SettingsTableViewModel) {
        self.tableView.configure(viewModel: viewModel)
    }

    func startLoading() {
        self.tableView.isHidden = true
        self.loadingIndicator.startAnimating()
    }

    func endLoading() {
        self.tableView.isHidden = false
        self.tableView.endRefreshing()

        self.loadingIndicator.stopAnimating()
    }
}

extension DebugMenuView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.tableView)
        self.addSubview(self.loadingIndicator)
    }

    func makeConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
    }
}
