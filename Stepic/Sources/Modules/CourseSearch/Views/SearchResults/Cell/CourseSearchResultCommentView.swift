import SnapKit
import UIKit

extension CourseSearchResultCommentView {
    struct Appearance {
        let separatorHeight: CGFloat = 0.5
        let separatorBackgroundColor = UIColor.stepikSeparator
        let separatorInsets = LayoutInsets(top: 16, right: -16)

        let avatarImageViewInsets = LayoutInsets(top: 16, left: 16)
        let avatarImageViewSize = CGSize(width: 36, height: 36)
        let avatarImageViewCornerRadius: CGFloat = 6

        let nameLabelInsets = LayoutInsets(left: 16)
        let nameLabelFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let nameLabelTextColor = UIColor.stepikMaterialPrimaryText
        let nameLabelHeight: CGFloat = 18

        let textLabelInsets = LayoutInsets(top: 4, left: 16)
        let textLabelFont = UIFont.systemFont(ofSize: 15)
        let textLabelTextColor = UIColor.stepikMaterialPrimaryText
    }
}

final class CourseSearchResultCommentView: UIControl {
    let appearance: Appearance

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorBackgroundColor
        return view
    }()

    private lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView()
        view.shape = .rectangle(cornerRadius: self.appearance.avatarImageViewCornerRadius)
        return view
    }()

    private lazy var avatarOverlayButton: UIButton = {
        let button = HighlightFakeButton()
        button.highlightedBackgroundColor = UIColor.stepikTertiaryBackground.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(self.avatarButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nameLabelFont
        label.textColor = self.appearance.nameLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textLabelFont
        label.textColor = self.appearance.textLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    var avatarImageURL: URL? {
        didSet {
            if let avatarImageURL = self.avatarImageURL {
                self.avatarImageView.set(with: avatarImageURL)
            } else {
                self.avatarImageView.reset()
            }
        }
    }

    var username: String? {
        get {
            self.nameLabel.text
        }
        set {
            self.nameLabel.text = newValue
        }
    }

    var text: String? {
        get {
            self.textLabel.text
        }
        set {
            self.textLabel.text = newValue
        }
    }

    var onAvatarClick: (() -> Void)?

    override var isHighlighted: Bool {
        didSet {
            [self.avatarImageView, self.nameLabel, self.textLabel].forEach { $0.alpha = self.isHighlighted ? 0.5 : 1.0 }
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

    @objc
    private func avatarButtonClicked() {
        self.onAvatarClick?()
    }
}

extension CourseSearchResultCommentView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.separatorView)
        self.addSubview(self.avatarImageView)
        self.addSubview(self.avatarOverlayButton)
        self.addSubview(self.nameLabel)
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(self.appearance.separatorInsets.edgeInsets)
            make.height.equalTo(self.appearance.separatorHeight)
        }

        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(self.separatorView.snp.bottom).offset(self.appearance.avatarImageViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.avatarImageViewInsets.left)
            make.size.equalTo(self.appearance.avatarImageViewSize)
        }

        self.avatarOverlayButton.translatesAutoresizingMaskIntoConstraints = false
        self.avatarOverlayButton.snp.makeConstraints { $0.edges.equalTo(self.avatarImageView) }

        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.avatarImageView.snp.top)
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.nameLabelInsets.left)
            make.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.nameLabelHeight)
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.textLabel.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(self.appearance.textLabelInsets.top)
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.textLabelInsets.left)
            make.bottom.trailing.equalToSuperview()
        }
    }
}
