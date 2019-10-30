import SnapKit
import UIKit

extension NewDiscussionsCellView {
    struct Appearance {
        let avatarImageViewInsets = LayoutInsets(top: 16, left: 16)
        let avatarImageViewSize = CGSize(width: 36, height: 36)
        let avatarImageViewCornerRadius: CGFloat = 4.0

        let badgeLabelInsets = LayoutInsets(left: 16)
        let badgeLabelFont = UIFont.systemFont(ofSize: 10, weight: .medium)
        let badgeLabelTextColor = UIColor.white
        let badgeLabelBackgroundColor = UIColor.stepicGreen
        let badgeLabelCornerRadius: CGFloat = 10
        let badgeLabelHeight: CGFloat = 20

        let nameLabelInsets = LayoutInsets(top: 8, left: 16, right: 16)
        let nameLabelFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let nameLabelTextColor = UIColor.mainDark

        let contentTextViewInsets = LayoutInsets(top: 8, right: 16)
        let contentTextViewDefaultHeight: CGFloat = 5

        let bottomControlsSpacing: CGFloat = 4
        let bottomControlsInsets = LayoutInsets(top: 8, left: 16, bottom: 16, right: 16)
        let bottomControlsHeight: CGFloat = 20

        let dateLabelFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let dateLabelTextColor = UIColor.mainDark

        let replyButtonFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let replyButtonTextColor = UIColor(hex: 0x3E50CB)

        let likeImageSize = CGSize(width: 20, height: 20)
        let likeImageNormalTintColor = UIColor.mainDark.withAlphaComponent(0.5)
        let likeImageFilledTintColor = UIColor.mainDark
        let likeButtonFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let likeButtonTitleInsets = UIEdgeInsets(top: 2, left: 4, bottom: 0, right: 0)

        let dislikeButtonTitleInsets = UIEdgeInsets(top: 2, left: 4, bottom: 0, right: 0)
    }
}

final class NewDiscussionsCellView: UIView {
    let appearance: Appearance

    private lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView()
        view.shape = .rectangle(cornerRadius: self.appearance.avatarImageViewCornerRadius)
        return view
    }()

    private lazy var badgeLabel: UILabel = {
        let label = WiderLabel()
        label.font = self.appearance.badgeLabelFont
        label.textColor = self.appearance.badgeLabelTextColor
        label.backgroundColor = self.appearance.badgeLabelBackgroundColor
        label.textAlignment = .center
        label.numberOfLines = 1

        label.layer.cornerRadius = self.appearance.badgeLabelCornerRadius
        label.layer.masksToBounds = true
        label.clipsToBounds = true

        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nameLabelFont
        label.textColor = self.appearance.nameLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var contentTextView: ProcessedContentTextView = {
        var appearance = ProcessedContentTextView.Appearance()
        appearance.insets = LayoutInsets(insets: .zero)
        appearance.backgroundColor = .clear

        let view = ProcessedContentTextView(appearance: appearance)
        view.delegate = self

        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        return view
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.dateLabelFont
        label.textColor = self.appearance.dateLabelTextColor
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private lazy var replyButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = self.appearance.replyButtonFont
        button.setTitleColor(self.appearance.replyButtonTextColor, for: .normal)
        button.setTitle(NSLocalizedString("Reply", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(self.replyDidClick), for: .touchUpInside)
        return button
    }()

    private lazy var likeImageButton: ImageButton = {
        let imageButton = ImageButton()
        imageButton.imageSize = self.appearance.likeImageSize
        imageButton.tintColor = self.appearance.likeImageNormalTintColor
        imageButton.font = self.appearance.likeButtonFont
        imageButton.title = "0"
        imageButton.image = UIImage(named: "discussions-thumb-up")?.withRenderingMode(.alwaysTemplate)
        imageButton.titleInsets = self.appearance.likeButtonTitleInsets
        imageButton.addTarget(self, action: #selector(self.likeDidClick), for: .touchUpInside)
        return imageButton
    }()

    private lazy var dislikeImageButton: ImageButton = {
        let imageButton = ImageButton()
        imageButton.imageSize = self.appearance.likeImageSize
        imageButton.tintColor = self.appearance.likeImageNormalTintColor
        imageButton.font = self.appearance.likeButtonFont
        imageButton.title = "0"
        imageButton.image = UIImage(named: "discussions-thumb-down")?.withRenderingMode(.alwaysTemplate)
        imageButton.titleInsets = self.appearance.dislikeButtonTitleInsets
        imageButton.addTarget(self, action: #selector(self.dislikeDidClick), for: .touchUpInside)
        return imageButton
    }()

    private lazy var bottomControlsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [self.dateLabel, self.replyButton, self.likeImageButton, self.dislikeImageButton]
        )
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = self.appearance.bottomControlsSpacing
        return stackView
    }()

    var contentHeight: CGFloat {
        let userInfoHeight = (self.badgeLabel.isHidden ? 0 : self.appearance.badgeLabelHeight)
            + (self.badgeLabel.isHidden ? 0 : self.appearance.nameLabelInsets.top)
            + self.nameLabel.intrinsicContentSize.height
        return self.appearance.avatarImageViewInsets.top
            + userInfoHeight
            + self.appearance.contentTextViewInsets.top
            + self.contentTextViewHeight
            + self.appearance.bottomControlsInsets.top
            + self.appearance.bottomControlsHeight
            + self.appearance.bottomControlsInsets.bottom
    }

    private lazy var contentTextViewHeight: CGFloat = self.appearance.contentTextViewDefaultHeight

    // Dynamically show/hide badge
    private var badgeLabelHeightConstraint: Constraint?
    private var nameLabelTopConstraint: Constraint?

    var onReplyClick: (() -> Void)?
    var onLikeClick: (() -> Void)?
    var onDislikeClick: (() -> Void)?
    // Dynamic content callbacks
    var onContentLoaded: (() -> Void)?
    var onNewHeightUpdate: (() -> Void)?

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    // MARK: - Public API

    func configure(viewModel: NewDiscussionsCommentViewModel?) {
        guard let viewModel = viewModel else {
            self.updateBadge(text: "", isHidden: true)
            self.nameLabel.text = nil
            self.dateLabel.text = nil
            self.updateVotes(likes: 0, dislikes: 0, voteValue: nil, canVote: false)
            self.avatarImageView.reset()
            self.contentTextView.isHidden = true
            self.contentTextView.reset()
            return
        }

        switch viewModel.userRole {
        case .student:
            self.updateBadge(text: "", isHidden: true)
        case .teacher:
            self.updateBadge(text: NSLocalizedString("CourseStaff", comment: ""), isHidden: false)
        case .staff:
            self.updateBadge(text: NSLocalizedString("Staff", comment: ""), isHidden: false)
        }

        self.updateVotes(
            likes: viewModel.likesCount,
            dislikes: viewModel.dislikesCount,
            voteValue: viewModel.voteValue,
            canVote: viewModel.canVote
        )

        self.nameLabel.text = viewModel.userName
        self.dateLabel.text = viewModel.dateRepresentation
        self.contentTextView.loadHTMLText(viewModel.text)

        if let url = viewModel.avatarImageURL {
            self.avatarImageView.set(with: url)
        }
    }

    // MARK: - Private API

    private func updateBadge(text: String, isHidden: Bool) {
        self.badgeLabel.text = text
        self.badgeLabel.isHidden = isHidden
        self.badgeLabelHeightConstraint?.update(offset: isHidden ? 0 : self.appearance.badgeLabelHeight)
        self.nameLabelTopConstraint?.update(offset: isHidden ? 0 : self.appearance.nameLabelInsets.top)
    }

    private func updateVotes(likes: Int, dislikes: Int, voteValue: VoteValue?, canVote: Bool) {
        self.likeImageButton.title = "\(likes)"
        self.dislikeImageButton.title = "\(dislikes)"

        if let voteValue = voteValue {
            if voteValue == .epic {
                self.likeImageButton.tintColor = self.appearance.likeImageFilledTintColor
            } else {
                self.dislikeImageButton.tintColor = self.appearance.likeImageFilledTintColor
            }
        } else {
            self.likeImageButton.tintColor = self.appearance.likeImageNormalTintColor
            self.dislikeImageButton.tintColor = self.appearance.likeImageNormalTintColor
        }

        self.likeImageButton.isEnabled = canVote
        self.dislikeImageButton.isEnabled = canVote
    }

    @objc
    private func replyDidClick() {
        self.onReplyClick?()
    }

    @objc
    private func likeDidClick() {
        self.onLikeClick?()
    }

    @objc
    private func dislikeDidClick() {
        self.onDislikeClick?()
    }
}

// MARK: - NewDiscussionsCellView: ProgrammaticallyInitializableViewProtocol -

extension NewDiscussionsCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.badgeLabel)
        self.addSubview(self.nameLabel)
        self.addSubview(self.contentTextView)
        self.addSubview(self.bottomControlsStackView)
    }

    func makeConstraints() {
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.avatarImageViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.avatarImageViewInsets.top)
            make.size.equalTo(self.appearance.avatarImageViewSize)
        }

        self.badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.badgeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.badgeLabelInsets.left)
            make.top.equalTo(self.avatarImageView.snp.top)
            self.badgeLabelHeightConstraint = make.height.equalTo(self.appearance.badgeLabelHeight).constraint
        }

        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.nameLabelInsets.left)
            self.nameLabelTopConstraint = make.top.equalTo(self.badgeLabel.snp.bottom)
                .offset(self.appearance.nameLabelInsets.top).constraint
            make.trailing.equalToSuperview().offset(-self.appearance.nameLabelInsets.right)
        }

        self.contentTextView.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(self.appearance.contentTextViewInsets.top)
            make.leading.equalTo(self.nameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-self.appearance.contentTextViewInsets.right)
        }

        self.bottomControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomControlsStackView.snp.makeConstraints { make in
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.bottomControlsInsets.left)
            make.top.greaterThanOrEqualTo(self.contentTextView.snp.bottom)
                .offset(self.appearance.bottomControlsInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.bottomControlsInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.bottomControlsInsets.bottom)
            make.height.equalTo(self.appearance.bottomControlsHeight)
        }
    }
}

// MARK: - NewDiscussionsCellView: ProcessedContentTextViewDelegate -

extension NewDiscussionsCellView: ProcessedContentTextViewDelegate {
    func processedContentTextViewDidLoadContent(_ view: ProcessedContentTextView) {
        self.contentTextViewHeight = CGFloat(self.contentTextView.currentWebViewHeight)
        self.contentTextView.isHidden = false
        self.onContentLoaded?()
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didReportNewHeight height: Int) {
        let newHeight = CGFloat(height)
        if newHeight != self.contentTextViewHeight {
            self.contentTextViewHeight = newHeight
            self.onNewHeightUpdate?()
        }
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenImage url: URL) { }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenLink url: URL) { }
}
