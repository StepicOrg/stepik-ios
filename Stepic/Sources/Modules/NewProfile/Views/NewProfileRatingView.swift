import SnapKit
import UIKit

extension NewProfileRatingView {
    struct Appearance {
        let iconImageViewSize = CGSize(width: 16, height: 16)

        let textLabelTextColor = UIColor.stepikSystemSecondaryText
        let textLabelRegularFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        let textLabelNumberValueFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        let textLabelInsets = LayoutInsets(left: 8)
    }
}

final class NewProfileRatingView: UIView {
    let appearance: Appearance
    let kind: Kind

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: self.kind.iconImage)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    var number: Int? {
        didSet {
            self.updateText()
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(self.appearance.iconImageViewSize.height, self.textLabel.intrinsicContentSize.height)
        )
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        kind: Kind
    ) {
        self.appearance = appearance
        self.kind = kind

        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateText()
        }
    }

    private func updateText() {
        guard let number = self.number else {
            return
        }

        let numberString = self.kind.numberToString(number)
        let formattedTitle = self.kind.makeFormattedTitle(number: number)

        let attributedText = NSMutableAttributedString(
            string: formattedTitle,
            attributes: [
                .font: self.appearance.textLabelRegularFont,
                .foregroundColor: self.appearance.textLabelTextColor
            ]
        )

        if let numberLocation = formattedTitle.indexOf(numberString) {
            attributedText.addAttributes(
                [.font: self.appearance.textLabelNumberValueFont],
                range: NSRange(location: numberLocation, length: numberString.count)
            )
        }

        self.textLabel.attributedText = attributedText
    }

    enum Kind {
        case knowledge
        case reputation
        case certificates
        case courses

        fileprivate var iconImage: UIImage? {
            switch self {
            case .knowledge:
                return UIImage(named: "new_profile_knowledge")
            case .reputation:
                return UIImage(named: "new_profile_reputation")
            case .certificates:
                return UIImage(named: "new_profile_certificates")
            case .courses:
                return UIImage(named: "new_profile_courses")
            }
        }

        fileprivate func numberToString(_ number: Int) -> String {
            switch self {
            case .knowledge, .reputation, .courses:
                return "\(number)"
            case .certificates:
                return FormatterHelper.longNumber(number)
            }
        }

        fileprivate func makeFormattedTitle(number: Int) -> String {
            let numberString = self.numberToString(number)

            switch self {
            case .knowledge:
                return String(
                    format: NSLocalizedString("NewProfileRatingKnowledge", comment: ""),
                    arguments: [numberString]
                )
            case .reputation:
                return String(
                    format: NSLocalizedString("NewProfileRatingReputation", comment: ""),
                    arguments: [numberString]
                )
            case .certificates:
                let pluralizedString = StringHelper.pluralize(
                    number: number,
                    forms: [
                        NSLocalizedString("NewProfileRatingCertificates1", comment: ""),
                        NSLocalizedString("NewProfileRatingCertificates234", comment: ""),
                        NSLocalizedString("NewProfileRatingCertificates567890", comment: "")
                    ]
                )
                return String(format: pluralizedString, arguments: [numberString])
            case .courses:
                let pluralizedString = StringHelper.pluralize(
                    number: number,
                    forms: [
                        NSLocalizedString("NewProfileRatingCourses1", comment: ""),
                        NSLocalizedString("NewProfileRatingCourses234", comment: ""),
                        NSLocalizedString("NewProfileRatingCourses567890", comment: "")
                    ]
                )
                return String(format: pluralizedString, arguments: [numberString])
            }
        }
    }
}

extension NewProfileRatingView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(self.appearance.iconImageViewSize.width)
            make.height.equalTo(self.appearance.iconImageViewSize.height)
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.leading
                .equalTo(self.iconImageView.snp.trailing)
                .offset(self.appearance.textLabelInsets.left)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.iconImageView.snp.centerY)
        }
    }
}
