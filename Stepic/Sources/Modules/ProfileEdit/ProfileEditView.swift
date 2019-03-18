import SnapKit
import UIKit

protocol ProfileEditViewDelegate: SettingsTableViewDelegate {
    func profileEditViewDidReportSaveButtonClick(_ profileEditView: ProfileEditView)
}

extension ProfileEditView {
    struct Appearance {
        let saveButtonHeight: CGFloat = 50
        let saveButtonInsets = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        let saveButtonBackgroundColor = UIColor(hex: 0x007AFF)
        let saveButtonTitleColor = UIColor.white
        let saveButtonTitleFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        let saveButtonCornerRadius: CGFloat = 10
    }
}

final class ProfileEditView: UIView {
    let appearance: Appearance
    weak var delegate: ProfileEditViewDelegate? {
        didSet {
            self.tableView.delegate = self.delegate
        }
    }

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(self.appearance.saveButtonTitleColor, for: .normal)
        button.backgroundColor = self.appearance.saveButtonBackgroundColor
        button.titleLabel?.font = self.appearance.saveButtonTitleFont
        button.layer.masksToBounds = true
        button.layer.cornerRadius = self.appearance.saveButtonCornerRadius
        button.addTarget(self, action: #selector(self.saveButtonDidClick), for: .touchUpInside)

        return button
    }()

    private lazy var tableView = SettingsTableView()

    var isSaveButtonEnabled: Bool {
        get {
            return self.saveButton.isEnabled
        }
        set {
            self.saveButton.isEnabled = newValue
            self.saveButton.alpha = newValue ? 1.0 : 0.5
        }
    }

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

    @objc
    private func saveButtonDidClick() {
        self.delegate?.profileEditViewDidReportSaveButtonClick(self)
    }
}

extension ProfileEditView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.tableView)
        self.addSubview(self.saveButton)
    }

    func makeConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.saveButton.translatesAutoresizingMaskIntoConstraints = false
        self.saveButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.saveButtonInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.saveButtonInsets.right)
            if #available(iOS 11.0, *) {
                make.bottom
                    .equalTo(self.safeAreaLayoutGuide.snp.bottom)
                    .offset(-self.appearance.saveButtonInsets.bottom)
            } else {
                make.bottom.equalToSuperview().offset(-self.appearance.saveButtonInsets.bottom)
            }
            make.height.equalTo(self.appearance.saveButtonHeight)
        }
    }
}
