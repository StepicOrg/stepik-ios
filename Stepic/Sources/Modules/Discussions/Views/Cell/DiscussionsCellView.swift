import SnapKit
import UIKit

extension DiscussionsCellView {
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

        let dotsMenuImageSize = CGSize(width: 20, height: 20)
        let dotsMenuImageTintColor = UIColor.mainDark.withAlphaComponent(0.5)
        let dotsMenuImageInsets = LayoutInsets(top: 16, right: 16)

        let nameLabelInsets = LayoutInsets(top: 8, left: 16, right: 16)
        let nameLabelFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let nameLabelTextColor = UIColor.mainDark
        let nameLabelHeight: CGFloat = 18

        let textContentContainerViewInsets = LayoutInsets(top: 8, bottom: 8, right: 16)
        let textContentWebBasedTextViewDefaultHeight: CGFloat = 5
        let textContentTextLabelFontSize: CGFloat = 14
        let textContentTextLabelFont = UIFont.systemFont(ofSize: 14)
        let textContentTextLabelTextColor = UIColor.mainDark

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

// MARK: - DiscussionsCellView: UIView -

final class DiscussionsCellView: UIView {
    let appearance: Appearance

    private lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView()
        view.shape = .rectangle(cornerRadius: self.appearance.avatarImageViewCornerRadius)
        return view
    }()

    private lazy var avatarOverlayButton: UIButton = {
        let button = HighlightFakeButton()
        button.highlightedBackgroundColor = UIColor.white.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(self.avatarOverlayButtonClicked), for: .touchUpInside)
        return button
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

    private lazy var dotsMenuImageButton: ImageButton = {
        let imageButton = ImageButton()
        imageButton.imageSize = self.appearance.dotsMenuImageSize
        imageButton.tintColor = self.appearance.dotsMenuImageTintColor
        imageButton.image = UIImage(named: "discussions-dots-menu")?.withRenderingMode(.alwaysTemplate)
        imageButton.addTarget(self, action: #selector(self.dotsMenuDidClick), for: .touchUpInside)
        return imageButton
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nameLabelFont
        label.textColor = self.appearance.nameLabelTextColor
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()

    private lazy var textContentWebBasedTextView: ProcessedContentTextView = {
        var appearance = ProcessedContentTextView.Appearance()
        appearance.insets = LayoutInsets(insets: .zero)
        appearance.backgroundColor = .clear

        let view = ProcessedContentTextView(appearance: appearance)
        view.delegate = self
        view.isHidden = true

        return view
    }()

    private lazy var textContentTextLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textContentTextLabelFont
        label.textColor = self.appearance.textContentTextLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var textContentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.textContentWebBasedTextView, self.textContentTextLabel])
        stackView.axis = .vertical
        stackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        stackView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return stackView
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

    // Dynamically show/hide badge
    private var badgeLabelHeightConstraint: Constraint?
    private var nameLabelTopConstraint: Constraint?

    // Keeps track of web content text view height
    private var currentWebBasedTextViewHeight = Appearance().textContentWebBasedTextViewDefaultHeight
    private var currentText: String?

    var onDotsMenuClick: (() -> Void)?
    var onReplyClick: (() -> Void)?
    var onLikeClick: (() -> Void)?
    var onDislikeClick: (() -> Void)?
    var onAvatarClick: (() -> Void)?
    var onLinkClick: ((URL) -> Void)?
    // Content height updates callbacks
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

    func configure(viewModel: DiscussionsCommentViewModel?) {
        guard let viewModel = viewModel else {
            return self.resetViews()
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

        self.nameLabel.text = viewModel.username
        self.dateLabel.text = viewModel.formattedDate

        self.updateTextContent(text: viewModel.text, isWebViewSupportNeeded: viewModel.isWebViewSupportNeeded)

        if let url = viewModel.avatarImageURL {
            self.avatarImageView.set(with: url)
        }
    }

    func calculateContentHeight(maxPreferredWidth: CGFloat) -> CGFloat {
        let userInfoHeight = (self.badgeLabel.isHidden ? 0 : self.appearance.badgeLabelHeight)
            + (self.badgeLabel.isHidden ? 0 : self.appearance.nameLabelInsets.top)
            + self.appearance.nameLabelHeight
        return self.appearance.avatarImageViewInsets.top
            + userInfoHeight
            + self.appearance.textContentContainerViewInsets.top
            + self.getTextContentHeight(maxPreferredWidth: maxPreferredWidth)
            + self.appearance.bottomControlsInsets.top
            + self.appearance.bottomControlsHeight
            + self.appearance.bottomControlsInsets.bottom
    }

    // MARK: - Private API

    private func resetViews() {
        self.updateBadge(text: "", isHidden: true)
        self.nameLabel.text = nil
        self.dateLabel.text = nil
        self.updateVotes(likes: 0, dislikes: 0, voteValue: nil, canVote: false)
        self.avatarImageView.reset()
        self.updateTextContent(text: "", isWebViewSupportNeeded: false)
    }

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

    private func updateTextContent(text: String, isWebViewSupportNeeded: Bool) {
        self.currentText = text

        if isWebViewSupportNeeded {
            self.textContentTextLabel.text = nil
            self.textContentTextLabel.isHidden = true

            self.textContentWebBasedTextView.alpha = 0
            self.textContentWebBasedTextView.isHidden = false
            self.currentWebBasedTextViewHeight = self.appearance.textContentWebBasedTextViewDefaultHeight
            self.textContentWebBasedTextView.loadHTMLText(text)
        } else {
            self.textContentWebBasedTextView.isHidden = true
            self.currentWebBasedTextViewHeight = self.appearance.textContentWebBasedTextViewDefaultHeight
            self.textContentWebBasedTextView.reset()

            self.textContentTextLabel.isHidden = false
            self.textContentTextLabel.setTextWithHTMLString(text)
        }
    }

    private func getTextContentHeight(maxPreferredWidth: CGFloat) -> CGFloat {
        if self.textContentWebBasedTextView.isHidden {
            let remainingTextContentWidth = maxPreferredWidth
                - self.appearance.avatarImageViewInsets.left
                - self.appearance.avatarImageViewSize.width
                - self.appearance.nameLabelInsets.left
                - self.appearance.textContentContainerViewInsets.right

            return UILabel.heightForLabelWithText(
                self.currentText ?? "",
                lines: self.textContentTextLabel.numberOfLines,
                standardFontOfSize: self.appearance.textContentTextLabelFontSize,
                width: remainingTextContentWidth,
                html: true,
                alignment: self.textContentTextLabel.textAlignment
            )
        }

        return self.currentWebBasedTextViewHeight
    }

    // MARK: Actions

    @objc
    private func dotsMenuDidClick() {
        self.onDotsMenuClick?()
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

    @objc
    private func avatarOverlayButtonClicked() {
        self.onAvatarClick?()
    }
}

// MARK: - DiscussionsCellView: ProgrammaticallyInitializableViewProtocol -

extension DiscussionsCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.avatarOverlayButton)
        self.addSubview(self.badgeLabel)
        self.addSubview(self.dotsMenuImageButton)
        self.addSubview(self.nameLabel)
        self.addSubview(self.textContentStackView)
        self.addSubview(self.bottomControlsStackView)
    }

    func makeConstraints() {
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.avatarImageViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.avatarImageViewInsets.top)
            make.size.equalTo(self.appearance.avatarImageViewSize)
        }

        self.avatarOverlayButton.translatesAutoresizingMaskIntoConstraints = false
        self.avatarOverlayButton.snp.makeConstraints { make in
            make.edges.equalTo(self.avatarImageView)
        }

        self.badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.badgeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.badgeLabelInsets.left)
            make.top.equalTo(self.avatarImageView.snp.top)
            self.badgeLabelHeightConstraint = make.height.equalTo(self.appearance.badgeLabelHeight).constraint
        }

        self.dotsMenuImageButton.translatesAutoresizingMaskIntoConstraints = false
        self.dotsMenuImageButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.dotsMenuImageInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.dotsMenuImageInsets.right)
            make.size.equalTo(self.appearance.dotsMenuImageSize)
        }

        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.nameLabelInsets.left)
            self.nameLabelTopConstraint = make.top
                .equalTo(self.badgeLabel.snp.bottom)
                .offset(self.appearance.nameLabelInsets.top)
                .constraint
            make.trailing.equalToSuperview().offset(-self.appearance.nameLabelInsets.right)
            make.height.equalTo(self.appearance.nameLabelHeight)
        }

        self.textContentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.textContentStackView.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(self.appearance.textContentContainerViewInsets.top)
            make.leading.equalTo(self.nameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-self.appearance.textContentContainerViewInsets.right)
            make.bottom
                .equalTo(self.bottomControlsStackView.snp.top)
                .offset(-self.appearance.textContentContainerViewInsets.bottom)
        }

        self.bottomControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomControlsStackView.snp.makeConstraints { make in
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.bottomControlsInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.bottomControlsInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.bottomControlsInsets.bottom)
            make.height.equalTo(self.appearance.bottomControlsHeight)
        }
    }
}

// MARK: - DiscussionsCellView: ProcessedContentTextViewDelegate -

extension DiscussionsCellView: ProcessedContentTextViewDelegate {
    func processedContentTextViewDidLoadContent(_ view: ProcessedContentTextView) {
        if self.textContentWebBasedTextView.isHidden {
            return
        }

        self.currentWebBasedTextViewHeight = CGFloat(self.textContentWebBasedTextView.currentWebViewHeight)
        self.textContentWebBasedTextView.alpha = 1
        self.onContentLoaded?()
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didReportNewHeight height: Int) {
        if self.textContentWebBasedTextView.isHidden {
            return
        }

        let newHeight = CGFloat(height)
        if newHeight != self.currentWebBasedTextViewHeight {
            self.currentWebBasedTextViewHeight = newHeight
            self.onNewHeightUpdate?()
        }
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenImage url: URL) { }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenLink url: URL) {
        self.onLinkClick?(url)
    }
}
