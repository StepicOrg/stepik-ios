import SnapKit
import UIKit

protocol SettingsStepFontSizeViewDelegate: class {
    func settingsStepFontSizeView(
        _ view: SettingsStepFontSizeView,
        didSelectFontSize viewModelUniqueIdentifier: UniqueIdentifierType
    )
}

extension SettingsStepFontSizeView {
    struct Appearance {
        let backgroundColor = UIColor.white
        let tableViewBackgroundColor = UIColor.clear
    }
}

final class SettingsStepFontSizeView: UIView {
    weak var delegate: SettingsStepFontSizeViewDelegate?

    let appearance: Appearance

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = self.appearance.tableViewBackgroundColor

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60.5

        tableView.register(cellClass: SettingsStepFontSizeTableViewCell.self)

        return tableView
    }()

    private var tableViewDataSource: (UITableViewDataSource & UITableViewDelegate)? {
        didSet {
            self.tableView.dataSource = self.tableViewDataSource
            self.tableView.delegate = self.tableViewDataSource
            self.tableView.reloadData()
        }
    }

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

    // MARK: - Public API

    func configure(viewModels: [SettingsStepFontSizeViewModel]) {
        let dataSource = SettingsStepFontSizeTableViewDataSource(viewModels: viewModels)
        dataSource.onViewModelSelected = { [weak self] viewModel in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.settingsStepFontSizeView(strongSelf, didSelectFontSize: viewModel.uniqueIdentifier)
        }

        self.tableViewDataSource = dataSource
    }
}

extension SettingsStepFontSizeView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.tableView)
    }

    func makeConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
