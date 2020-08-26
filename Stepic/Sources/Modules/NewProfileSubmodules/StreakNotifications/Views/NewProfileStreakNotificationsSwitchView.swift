import SnapKit
import UIKit

extension NewProfileStreakNotificationsSwitchView {
    struct Appearance {
        let textLabelFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        let textLabelTextColor = UIColor.stepikSystemPrimaryText
        let textLabelInsets = LayoutInsets(left: 16)

        let switchControlInsets = LayoutInsets(left: 8, right: 16)

        let separatorHeight: CGFloat = 0.5
        let separatorColor = UIColor.stepikSeparator

        let backgroundColor = UIColor.stepikSecondaryGroupedBackground
    }
}

final class NewProfileStreakNotificationsSwitchView: UIView {
    let appearance: Appearance

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.textLabelTextColor
        label.font = self.appearance.textLabelFont
        label.numberOfLines = 1
        label.text = NSLocalizedString("NewProfileStreakNotificationsNotifyPreference", comment: "")
        return label
    }()

    private lazy var switchControl: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.addTarget(self, action: #selector(self.switchValueChanged), for: .valueChanged)
        return uiSwitch
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    var streakNotificationsSwitchTooltipAnchorView: UIView { self.switchControl }
    
    var isOn: Bool = false {
        didSet {
            self.switchControl.isOn = isOn
        }
    }

    var isSeparatorHidden: Bool = false {
        didSet {
            self.separatorView.isHidden = self.isSeparatorHidden
        }
    }

    var onSwitchValueChanged: ((Bool) -> Void)?

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

    @objc
    private func switchValueChanged() {
        self.onSwitchValueChanged?(self.switchControl.isOn)
    }
}

extension NewProfileStreakNotificationsSwitchView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.textLabel)
        self.addSubview(self.switchControl)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.textLabelInsets.left)
            make.centerY.equalToSuperview()
        }

        self.switchControl.translatesAutoresizingMaskIntoConstraints = false
        self.switchControl.snp.makeConstraints { make in
            make.leading
                .greaterThanOrEqualTo(self.textLabel.snp.trailing)
                .offset(self.appearance.switchControlInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.switchControlInsets.right)
            make.centerY.equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.equalTo(self.textLabel.snp.leading)
            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }
    }
}
