import SnapKit
import UIKit

extension SettingsRightDetailCellView {
    struct Appearance {
        let titleTextColor = UIColor.stepikSystemPrimaryText
        let titleFont = UIFont.systemFont(ofSize: 17)
        let titleInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 8)

        let detailTextColor = UIColor.stepikSystemSecondaryText
        let detailFont = UIFont.systemFont(ofSize: 17)
        let detailInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)

        let trailingOffsetWithAccessoryItem: CGFloat = 8
        let trailingOffsetWithoutAccessoryItem: CGFloat = 16

        let containerMinHeight: CGFloat = 44
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
        return label
    }()

    private lazy var containerView = UIView()

    private var titleLabelTrailingDetailLabelConstraint: Constraint?
    private var titleLabelTrailingSuperviewConstraint: Constraint?

    private var detailLabelTrailingConstraint: Constraint?

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var titleTextColor: UIColor = .stepikSystemPrimaryText {
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
            self.setDetailLabelHidden(self.detailText?.isEmpty ?? true)
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
        let trailingOffset: CGFloat = {
            switch accessoryType {
            case .none:
                return self.appearance.trailingOffsetWithoutAccessoryItem
            default:
                return self.appearance.trailingOffsetWithAccessoryItem
            }
        }()

        self.detailLabelTrailingConstraint?.update(offset: -trailingOffset)
        self.titleLabelTrailingSuperviewConstraint?.update(offset: -trailingOffset)
    }

    private func setDetailLabelHidden(_ isHidden: Bool) {
        if isHidden {
            self.titleLabelTrailingDetailLabelConstraint?.deactivate()
            self.titleLabelTrailingSuperviewConstraint?.activate()
        } else {
            self.titleLabelTrailingSuperviewConstraint?.deactivate()
            self.titleLabelTrailingDetailLabelConstraint?.activate()
        }
        self.detailLabel.isHidden = isHidden
    }
}

extension SettingsRightDetailCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.detailLabel)
    }

    func makeConstraints() {
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(self.appearance.containerMinHeight)
        }

        self.detailLabel.translatesAutoresizingMaskIntoConstraints = false
        self.detailLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.detailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.detailLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            self.detailLabelTrailingConstraint = make.trailing
                .equalToSuperview()
                .offset(self.appearance.detailInsets.right)
                .constraint
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.titleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(self.appearance.titleInsets)
            self.titleLabelTrailingDetailLabelConstraint = make.trailing
                .equalTo(self.detailLabel.snp.leading)
                .offset(-self.appearance.titleInsets.right)
                .constraint
            self.titleLabelTrailingSuperviewConstraint = make.trailing.equalToSuperview().constraint
            self.titleLabelTrailingSuperviewConstraint?.deactivate()
        }
    }
}
