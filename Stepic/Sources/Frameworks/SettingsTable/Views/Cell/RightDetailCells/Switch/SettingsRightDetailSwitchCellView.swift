import SnapKit
import UIKit

extension SettingsRightDetailSwitchCellView {
    struct Appearance {
        let titleTextColor = UIColor.stepikSystemPrimaryText
        let titleFont = UIFont.systemFont(ofSize: 17)
        let titleInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 8)

        let switchOnTintColor = UIColor.stepikSwitchOnTint
        let switchWidth: CGFloat = 51

        let trailingOffsetWithAccessoryItem: CGFloat = 8
        let trailingOffsetWithoutAccessoryItem: CGFloat = 16

        let containerMinHeight: CGFloat = 44
    }
}

final class SettingsRightDetailSwitchCellView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleTextColor
        label.font = self.appearance.titleFont
        label.numberOfLines = 0
        return label
    }()

    private lazy var detailSwitch: UISwitch = {
        let detailSwitch = UISwitch()
        detailSwitch.onTintColor = self.appearance.switchOnTintColor
        detailSwitch.addTarget(self, action: #selector(self.detailSwitchValueChanged), for: .valueChanged)
        return detailSwitch
    }()

    private lazy var containerView = UIView()

    private var detailSwitchTrailingConstraint: Constraint?

    var onSwitchValueChanged: ((Bool) -> Void)?

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var textColor: UIColor = .stepikSystemPrimaryText {
        didSet {
            self.titleLabel.textColor = self.textColor
        }
    }

    var textAlignment: NSTextAlignment = .natural {
        didSet {
            self.titleLabel.textAlignment = self.textAlignment
        }
    }

    var switchIsOn: Bool = false {
        didSet {
            self.detailSwitch.isOn = self.switchIsOn
        }
    }

    var switchOnTintColor: UIColor = .stepikSwitchOnTint {
        didSet {
            self.detailSwitch.onTintColor = self.switchOnTintColor
        }
    }

    override init(frame: CGRect) {
        self.appearance = .init()
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func handleAccessoryTypeUpdate(_ accessoryType: UITableViewCell.AccessoryType) {
        switch accessoryType {
        case .none:
            self.detailSwitchTrailingConstraint?.update(offset: -self.appearance.trailingOffsetWithoutAccessoryItem)
        default:
            self.detailSwitchTrailingConstraint?.update(offset: -self.appearance.trailingOffsetWithAccessoryItem)
        }
    }

    @objc
    private func detailSwitchValueChanged() {
        self.onSwitchValueChanged?(self.detailSwitch.isOn)
    }
}

extension SettingsRightDetailSwitchCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.detailSwitch)
    }

    func makeConstraints() {
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(self.appearance.containerMinHeight)
        }

        self.detailSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.detailSwitch.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.detailSwitch.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.detailSwitch.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.detailSwitch.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.detailSwitch.snp.makeConstraints { make in
            make.width.equalTo(self.appearance.switchWidth)
            make.centerY.equalToSuperview()
            self.detailSwitchTrailingConstraint = make.trailing
                .equalToSuperview()
                .offset(-self.appearance.trailingOffsetWithoutAccessoryItem)
                .constraint
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.titleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(self.appearance.titleInsets)
            make.trailing.equalTo(self.detailSwitch.snp.leading).offset(-self.appearance.titleInsets.right)
        }
    }
}
