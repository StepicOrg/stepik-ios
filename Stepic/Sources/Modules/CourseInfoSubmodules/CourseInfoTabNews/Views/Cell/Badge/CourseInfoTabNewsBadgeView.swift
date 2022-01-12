import SnapKit
import UIKit

extension CourseInfoTabNewsBadgeView {
    struct Appearance {
        let iconSize = CGSize(width: 12, height: 12)

        let textFont = Typography.caption2Font

        let stackViewSpacing: CGFloat = 4
        let stackViewInsets = LayoutInsets(top: 4, left: 8, bottom: 4, right: 8)
    }
}

final class CourseInfoTabNewsBadgeView: UIView {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textFont
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        let textLabelIntrinsicContentSize = self.textLabel.intrinsicContentSize

        let width = self.appearance.stackViewInsets.left
            + (self.iconImageView.isHidden ? 0 : self.appearance.iconSize.width)
            + (self.iconImageView.isHidden ? 0 : self.appearance.stackViewSpacing)
            + textLabelIntrinsicContentSize.width
            + self.appearance.stackViewInsets.right

        let height = self.appearance.stackViewInsets.top
            + max(self.appearance.iconSize.height, textLabelIntrinsicContentSize.height)
            + self.appearance.stackViewInsets.bottom

        return CGSize(width: width, height: height)
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundAllCorners(radius: self.intrinsicContentSize.height / 2)
    }

    func configure(type: BadgeType) {
        self.stackView.removeAllArrangedSubviews()

        self.stackView.addArrangedSubview(self.iconImageView)
        self.stackView.addArrangedSubview(self.textLabel)

        self.iconImageView.image = type.icon
        self.iconImageView.tintColor = type.tintColor
        self.iconImageView.isHidden = type.icon == nil

        self.textLabel.text = type.title
        self.textLabel.textColor = type.tintColor

        self.backgroundColor = type.backgroundColor

        self.invalidateIntrinsicContentSize()
    }

    enum BadgeType {
        case composing
        case scheduled
        case sending
        case sent
        case onEvent
        case oneTime

        fileprivate var icon: UIImage? {
            switch self {
            case .composing:
                return UIImage(named: "course-info-news-badge-eye-off")?.withRenderingMode(.alwaysTemplate)
            case .scheduled:
                return UIImage(named: "course-info-news-badge-timer")?.withRenderingMode(.alwaysTemplate)
            case .sending:
                return UIImage(named: "course-info-news-badge-mail")?.withRenderingMode(.alwaysTemplate)
            case .sent:
                return UIImage(named: "course-info-news-badge-correct")?.withRenderingMode(.alwaysTemplate)
            case .onEvent, .oneTime:
                return nil
            }
        }

        fileprivate var title: String {
            switch self {
            case .composing:
                return NSLocalizedString("CourseInfoTabNewsBadgeComposing", comment: "")
            case .scheduled:
                return NSLocalizedString("CourseInfoTabNewsBadgeScheduled", comment: "")
            case .sending:
                return NSLocalizedString("CourseInfoTabNewsBadgeSending", comment: "")
            case .sent:
                return NSLocalizedString("CourseInfoTabNewsBadgeSent", comment: "")
            case .onEvent:
                return NSLocalizedString("CourseInfoTabNewsBadgeOnEvent", comment: "")
            case .oneTime:
                return NSLocalizedString("CourseInfoTabNewsBadgeOneTime", comment: "")
            }
        }

        fileprivate var tintColor: UIColor {
            switch self {
            case .composing:
                return .stepikMaterialSecondaryText
            case .scheduled, .sending:
                return .dynamic(light: .stepikVioletFixed, dark: .stepikViolet05Fixed)
            case .sent:
                return .stepikGreen
            case .onEvent, .oneTime:
                return .stepikOverlayBlue
            }
        }

        fileprivate var backgroundColor: UIColor {
            switch self {
            case .composing:
                return .stepikOverlayOnSurfaceBackground
            case .scheduled, .sending:
                return .stepikOverlayVioletBackground
            case .sent:
                return .stepikOverlayGreenBackground
            case .onEvent, .oneTime:
                return .stepikOverlayBlueBackground
            }
        }
    }
}

extension CourseInfoTabNewsBadgeView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.iconSize)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.stackViewInsets.edgeInsets)
        }
    }
}
