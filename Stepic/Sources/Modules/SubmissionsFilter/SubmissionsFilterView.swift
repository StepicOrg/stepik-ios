import SnapKit
import UIKit

protocol SubmissionsFilterViewDelegate: SettingsTableViewDelegate {}

extension SubmissionsFilterView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground
    }
}

final class SubmissionsFilterView: UIView {
    let appearance: Appearance

    weak var delegate: SubmissionsFilterViewDelegate? {
        didSet {
            self.tableView.delegate = self.delegate
        }
    }

    private lazy var tableView = SettingsTableView(appearance: .init(style: .stepikInsetGrouped))

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

extension SubmissionsFilterView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.tableView)
    }

    func makeConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
