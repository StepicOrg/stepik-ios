import SnapKit
import UIKit

extension SettingsRightDetailCellView {
    struct Appearance {
        let titleTextColor = UIColor.mainDark
        let titleFont = UIFont.systemFont(ofSize: 17)
        let titleInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)

        let detailTextColor = UIColor(hex: 0x8F8E94)
        let detailFont = UIFont.systemFont(ofSize: 17)

        let detailSwitchOnTintColor = UIColor.mainDark

        let detailStackViewHeight: CGFloat = 31
        let detailStackViewSmallTrailingOffset: CGFloat = 8
        let detailStackViewInsets = UIEdgeInsets(top: 6.5, left: 0, bottom: 6.5, right: 16)
    }
}

final class SettingsRightDetailCellView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleTextColor
        label.font = self.appearance.titleFont
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.detailTextColor
        label.font = self.appearance.detailFont
        label.numberOfLines = 1
        label.textAlignment = .right
        label.isHidden = true
        return label
    }()

    private lazy var detailSwitch: UISwitch = {
        let detailSwitch = UISwitch()
        detailSwitch.onTintColor = self.appearance.detailSwitchOnTintColor
        detailSwitch.isHidden = true
        return detailSwitch
    }()

    private lazy var detailStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.detailLabel, self.detailSwitch])
        stackView.axis = .horizontal
        stackView.spacing = 0
        return stackView
    }()

    private var titleLabelTrailingConstraint: Constraint?

    private var detailStackViewTrailingConstraint: Constraint?
    private var detailStackViewZeroWidthConstraint: Constraint?

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var titleTextColor: UIColor = .black {
        didSet {
            self.titleLabel.textColor = self.titleTextColor
        }
    }

    var titleTextAlignment: NSTextAlignment = .natural {
        didSet {
            self.titleLabel.textAlignment = self.titleTextAlignment
        }
    }

    var detailText: String? {
        didSet {
            self.detailLabel.text = self.detailText
            self.setDetailSubviewsHidden(except: self.detailLabel)
            self.setDetailsHidden(self.detailText?.isEmpty ?? true)
        }
    }

    var detailSwitchIsOn: Bool = false {
        didSet {
            self.detailSwitch.isOn = self.detailSwitchIsOn
            self.setDetailSubviewsHidden(except: self.detailSwitch)
            self.setDetailsHidden(false)
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
            self.detailStackViewTrailingConstraint?.update(offset: -self.appearance.detailStackViewInsets.right)
        default:
            self.detailStackViewTrailingConstraint?.update(offset: -self.appearance.detailStackViewSmallTrailingOffset)
        }
    }

    // MARK: Private API

    private func setDetailSubviewsHidden(except viewToKeepVisible: UIView) {
        self.detailStackView.arrangedSubviews.forEach { $0.isHidden = $0 !== viewToKeepVisible }
    }

    private func setDetailsHidden(_ isHidden: Bool) {
        if isHidden {
            self.detailStackViewZeroWidthConstraint?.activate()
            self.titleLabelTrailingConstraint?.update(offset: 0)
        } else {
            self.detailStackViewZeroWidthConstraint?.deactivate()
            self.titleLabelTrailingConstraint?.update(offset: -self.appearance.titleInsets.right)
        }
        self.detailStackView.isHidden = isHidden
    }
}

extension SettingsRightDetailCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.detailStackView)
    }

    func makeConstraints() {
        self.detailStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.detailStackView.translatesAutoresizingMaskIntoConstraints = false
        self.detailStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(self.appearance.detailStackViewHeight)
            make.top.bottom.greaterThanOrEqualToSuperview().inset(self.appearance.detailStackViewInsets).priority(999)
            self.detailStackViewTrailingConstraint = make.trailing
                .equalToSuperview()
                .offset(self.appearance.detailStackViewInsets.right)
                .constraint
            self.detailStackViewZeroWidthConstraint = make.width.equalTo(0).constraint
            self.detailStackViewZeroWidthConstraint?.deactivate()
        }

        self.titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(self.appearance.titleInsets)
            self.titleLabelTrailingConstraint = make.trailing
                .equalTo(self.detailStackView.snp.leading)
                .offset(-self.appearance.titleInsets.right)
                .constraint
        }
    }
}
