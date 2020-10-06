import SnapKit
import UIKit

extension DiscussionsBadgesView {
    struct Appearance {
        let badgeFont = UIFont.systemFont(ofSize: 10, weight: .medium)
        let badgeTintColor = UIColor.white
        let badgeCornerRadius: CGFloat = 10

        let userRoleBadgeLabelWidthDelta: CGFloat = 16
        let userRoleBadgeLabelBackgroundColor = UIColor.dynamic(light: .stepikGreenFixed, dark: .stepikDarkGreenFixed)

        let isPinnedImageButtonImageSize = CGSize(width: 10, height: 10)
        let isPinnedImageButtonImageInsets = UIEdgeInsets(top: 1, left: 8, bottom: 0, right: 2)
        let isPinnedImageButtonTitleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        let isPinnedImageButtonBackgroundColor = UIColor.dynamic(
            light: .stepikVioletFixed,
            dark: .stepikDarkVioletFixed
        )

        let stackViewSpacing: CGFloat = 8
    }
}

final class DiscussionsBadgesView: UIView {
    let appearance: Appearance

    private lazy var userRoleBadgeLabel: UILabel = {
        let label = WiderLabel()
        label.widthDelta = self.appearance.userRoleBadgeLabelWidthDelta
        label.font = self.appearance.badgeFont
        label.textColor = self.appearance.badgeTintColor
        label.backgroundColor = self.appearance.userRoleBadgeLabelBackgroundColor
        label.textAlignment = .center
        label.numberOfLines = 1
        label.layer.cornerRadius = self.appearance.badgeCornerRadius
        label.layer.masksToBounds = true
        label.clipsToBounds = true
        return label
    }()

    private lazy var isPinnedImageButton: ImageButton = {
        let imageButton = ImageButton()
        imageButton.imageSize = self.appearance.isPinnedImageButtonImageSize
        imageButton.imageInsets = self.appearance.isPinnedImageButtonImageInsets
        imageButton.titleInsets = self.appearance.isPinnedImageButtonTitleInsets
        imageButton.tintColor = self.appearance.badgeTintColor
        imageButton.font = self.appearance.badgeFont
        imageButton.title = NSLocalizedString("DiscussionsIsPinnedBadgeTitle", comment: "")
        imageButton.image = UIImage(named: "discussions-pin")?.withRenderingMode(.alwaysTemplate)
        imageButton.backgroundColor = self.appearance.isPinnedImageButtonBackgroundColor
        imageButton.disabledAlpha = 1.0
        imageButton.isEnabled = false
        imageButton.layer.cornerRadius = self.appearance.badgeCornerRadius
        imageButton.layer.masksToBounds = true
        imageButton.clipsToBounds = true
        return imageButton
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    var userRoleText: String? {
        didSet {
            self.userRoleBadgeLabel.text = self.userRoleText
            self.userRoleBadgeLabel.isHidden = self.userRoleText?.isEmpty ?? true
        }
    }

    var isPinned: Bool = true {
        didSet {
            self.isPinnedImageButton.isHidden = !self.isPinned
        }
    }

    var isAllBadgesHidden: Bool {
        self.userRoleBadgeLabel.isHidden && self.isPinnedImageButton.isHidden
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
}

extension DiscussionsBadgesView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.userRoleBadgeLabel)
        self.stackView.addArrangedSubview(self.isPinnedImageButton)
    }

    func makeConstraints() {
        self.stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
