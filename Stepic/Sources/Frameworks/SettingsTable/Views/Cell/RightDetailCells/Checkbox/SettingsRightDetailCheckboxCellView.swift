import BEMCheckBox
import SnapKit
import UIKit

extension SettingsRightDetailCheckboxCellView {
    struct Appearance {
        let titleTextColor = UIColor.stepikSystemPrimaryText
        let titleFont = Typography.bodyFont
        let titleInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 8)

        let checkBoxLineWidth: CGFloat = 2
        let checkBoxAnimationDuration: CGFloat = 0.5
        let checkBoxTintColor = UIColor.stepikAccentFixed
        let checkBoxOnCheckColor = UIColor.white
        let checkBoxOnFillColor = UIColor.stepikVioletFixed
        let checkBoxOnTintColor = UIColor.stepikVioletFixed
        let checkBoxWidthHeight: CGFloat = 20

        let trailingOffsetWithAccessoryItem: CGFloat = 8
        let trailingOffsetWithoutAccessoryItem: CGFloat = 16

        let containerMinHeight: CGFloat = 44
    }
}

final class SettingsRightDetailCheckboxCellView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleTextColor
        label.font = self.appearance.titleFont
        label.numberOfLines = 0
        return label
    }()

    private(set) lazy var checkBox: BEMCheckBox = {
        let checkBox = BEMCheckBox()
        checkBox.lineWidth = self.appearance.checkBoxLineWidth
        checkBox.hideBox = false
        checkBox.boxType = .circle
        checkBox.tintColor = self.appearance.checkBoxTintColor
        checkBox.onCheckColor = self.appearance.checkBoxOnCheckColor
        checkBox.onFillColor = self.appearance.checkBoxOnFillColor
        checkBox.onTintColor = self.appearance.checkBoxOnTintColor
        checkBox.animationDuration = self.appearance.checkBoxAnimationDuration
        checkBox.onAnimationType = .fill
        checkBox.offAnimationType = .fill
        checkBox.delegate = self
        return checkBox
    }()

    private lazy var containerView = UIView()

    private var detailCheckBoxTrailingConstraint: Constraint?

    var onCheckBoxValueChanged: ((Bool) -> Void)?

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

    var checkBoxIsOn: Bool {
        get {
            self.checkBox.on
        }
        set {
            self.checkBox.setOn(newValue, animated: false)
        }
    }

    override init(frame: CGRect) {
        self.appearance = .init()
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCheckBoxOn(_ isOn: Bool, animated: Bool) {
        self.checkBox.setOn(isOn, animated: animated)
    }

    func handleAccessoryTypeUpdate(_ accessoryType: UITableViewCell.AccessoryType) {
        switch accessoryType {
        case .none:
            self.detailCheckBoxTrailingConstraint?.update(offset: -self.appearance.trailingOffsetWithoutAccessoryItem)
        default:
            self.detailCheckBoxTrailingConstraint?.update(offset: -self.appearance.trailingOffsetWithAccessoryItem)
        }
    }
}

extension SettingsRightDetailCheckboxCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.checkBox)
    }

    func makeConstraints() {
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(self.appearance.containerMinHeight)
        }

        self.checkBox.translatesAutoresizingMaskIntoConstraints = false
        self.checkBox.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.checkBox.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.checkBox.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.checkBox.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.checkBox.snp.makeConstraints { make in
            make.width.height.equalTo(self.appearance.checkBoxWidthHeight)
            make.centerY.equalToSuperview()
            self.detailCheckBoxTrailingConstraint = make.trailing
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
            make.trailing.equalTo(self.checkBox.snp.leading).offset(-self.appearance.titleInsets.right)
        }
    }
}

extension SettingsRightDetailCheckboxCellView: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        self.onCheckBoxValueChanged?(checkBox.on)
    }
}
