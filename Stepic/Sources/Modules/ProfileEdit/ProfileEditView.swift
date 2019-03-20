import SnapKit
import UIKit

protocol ProfileEditViewDelegate: SettingsTableViewDelegate { }

extension ProfileEditView {
    struct Appearance { }
}

final class ProfileEditView: UIView {
    let appearance: Appearance
    weak var delegate: ProfileEditViewDelegate? {
        didSet {
            self.tableView.delegate = self.delegate
        }
    }

    private lazy var tableView = SettingsTableView()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(viewModel: SettingsTableViewModel) {
        self.tableView.update(viewModel: viewModel)
    }
}

extension ProfileEditView: ProgrammaticallyInitializableViewProtocol {
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
