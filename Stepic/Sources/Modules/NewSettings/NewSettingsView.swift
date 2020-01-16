import SnapKit
import UIKit

protocol NewSettingsViewDelegate: SettingsTableViewDelegate {}

extension NewSettingsView {
    struct Appearance {}
}

final class NewSettingsView: UIView {
    let appearance: Appearance
    weak var delegate: NewSettingsViewDelegate? {
        didSet {
            self.tableView.delegate = self.delegate
        }
    }

    private lazy var tableView = SettingsTableView(appearance: .init(style: .insetGroupedFallbackGrouped))

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
}

extension NewSettingsView: ProgrammaticallyInitializableViewProtocol {
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
