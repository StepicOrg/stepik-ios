import Atributika
import SnapKit
import UIKit

// swiftlint:disable file_length

// MARK: Appearance -

extension DiscussionsCellView {
    struct Appearance {
        let avatarImageViewInsets = LayoutInsets(top: 16, left: 16)
        let avatarImageViewSize = CGSize(width: 36, height: 36)
        let avatarImageViewCornerRadius: CGFloat = 4.0

        let badgeLabelFont = UIFont.systemFont(ofSize: 10, weight: .medium)
        let badgeTintColor = UIColor.white
        let badgeCornerRadius: CGFloat = 10

        let badgeUserRoleWidthDelta: CGFloat = 16
        let badgeUserRoleLightBackgroundColor = UIColor.stepikGreenFixed
        let badgeUserRoleDarkBackgroundColor = UIColor.stepikDarkGreenFixed

        let badgeIsPinnedLightBackgroundColor = UIColor.stepikVioletFixed
        let badgeIsPinnedDarkBackgroundColor = UIColor.stepikDarkVioletFixed
        let badgeIsPinnedImageSize = CGSize(width: 10, height: 10)
        let badgeIsPinnedImageInsets = UIEdgeInsets(top: 1, left: 8, bottom: 0, right: 2)
        let badgeIsPinnedTitleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)

        let badgesStackViewHeight: CGFloat = 20
        let badgesStackViewSpacing: CGFloat = 8
        let badgesStackViewInsets = LayoutInsets(top: 16, left: 16, right: 16)

        let nameLabelInsets = LayoutInsets(top: 8, left: 16, right: 16)
        let nameLabelFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let nameLabelTextColor = UIColor.stepikPrimaryText
        let nameLabelHeight: CGFloat = 18

        let textContentContainerViewInsets = LayoutInsets(top: 8, bottom: 8, right: 16)
        let textContentWebBasedTextViewDefaultHeight: CGFloat = 5
        let textContentTextLabelFontSize: CGFloat = 14
        let textContentTextLabelFont = UIFont.systemFont(ofSize: 14)
        let textContentTextLabelTextColor = UIColor.stepikPrimaryText

        let solutionControlHeight = DiscussionsSolutionControl.Appearance.height
        let solutionControlInsets = LayoutInsets(top: 8)

        let bottomControlsSpacing: CGFloat = 16
        let bottomControlsSubgroupSpacing: CGFloat = 8
        let bottomControlsInsets = LayoutInsets(top: 8, left: 16, bottom: 16, right: 16)
        let bottomControlsHeight: CGFloat = 20

        let dateLabelFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let dateLabelTextColor = UIColor.stepikPrimaryText

        let replyButtonFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let replyButtonTextColor = UIColor.stepikDarkVioletFixed

        // Like & dislike
        let voteImageSize = CGSize(width: 20, height: 20)
        let voteImageFilledTintColor = UIColor.stepikAccent
        let voteImageNormalTintColor = UIColor.stepikAccentAlpha50
        let voteImageDisabledTintColor = UIColor.stepikAccentAlpha25
        let voteButtonFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let voteLikeButtonTitleInsets = UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 0)
        let voteDislikeButtonTitleInsets = UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 0)
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
        button.highlightedBackgroundColor = UIColor.stepikTertiaryBackground.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(self.avatarButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var userRoleBadgeLabel: UILabel = {
        let label = WiderLabel()
        label.widthDelta = self.appearance.badgeUserRoleWidthDelta
        label.font = self.appearance.badgeLabelFont
        label.textColor = self.appearance.badgeTintColor
        label.backgroundColor = self.appearance.badgeUserRoleLightBackgroundColor
        label.textAlignment = .center
        label.numberOfLines = 1
        // Round corners
        label.layer.cornerRadius = self.appearance.badgeCornerRadius
        label.layer.masksToBounds = true
        label.clipsToBounds = true
        return label
    }()

    private lazy var isPinnedImageButton: ImageButton = {
        let imageButton = ImageButton()
        imageButton.imageSize = self.appearance.badgeIsPinnedImageSize
        imageButton.imageInsets = self.appearance.badgeIsPinnedImageInsets
        imageButton.titleInsets = self.appearance.badgeIsPinnedTitleInsets
        imageButton.tintColor = self.appearance.badgeTintColor
        imageButton.font = self.appearance.badgeLabelFont
        imageButton.title = NSLocalizedString("DiscussionsIsPinnedBadgeTitle", comment: "")
        imageButton.image = UIImage(named: "discussions-pin")?.withRenderingMode(.alwaysTemplate)
        imageButton.backgroundColor = self.appearance.badgeIsPinnedLightBackgroundColor
        imageButton.disabledAlpha = 1.0
        imageButton.isEnabled = false
        // Round corners
        imageButton.layer.cornerRadius = self.appearance.badgeCornerRadius
        imageButton.layer.masksToBounds = true
        imageButton.clipsToBounds = true
        return imageButton
    }()

    private lazy var badgesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.userRoleBadgeLabel, self.isPinnedImageButton])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = self.appearance.badgesStackViewSpacing
        stackView.isHidden = true
        return stackView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nameLabelFont
        label.textColor = self.appearance.nameLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var textContentWebBasedTextView: ProcessedContentWebView = {
        var appearance = ProcessedContentWebView.Appearance()
        appearance.insets = LayoutInsets(insets: .zero)
        appearance.backgroundColor = .clear
        let view = ProcessedContentWebView(appearance: appearance)
        view.delegate = self
        view.isHidden = true
        return view
    }()

    private lazy var textContentTextLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.numberOfLines = 0
        label.font = self.appearance.textContentTextLabelFont
        label.textColor = self.appearance.textContentTextLabelTextColor
        label.onClick = { [weak self] _, detection in
            if case .link(let url) = detection.type {
                self?.onLinkClick?(url)
            }
        }
        return label
    }()

    private lazy var textContentStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.textContentWebBasedTextView,
                self.textContentTextLabel,
                self.solutionContainerView
            ]
        )
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var solutionControl: DiscussionsSolutionControl = {
        let control = DiscussionsSolutionControl()
        control.addTarget(self, action: #selector(self.solutionControlClicked), for: .touchUpInside)
        return control
    }()

    private lazy var solutionContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
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
        button.addTarget(self, action: #selector(self.replyButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var likeImageButton: ImageButton = {
        let imageButton = ImageButton()
        imageButton.imageSize = self.appearance.voteImageSize
        imageButton.tintColor = self.appearance.voteImageNormalTintColor
        imageButton.font = self.appearance.voteButtonFont
        imageButton.title = "0"
        imageButton.image = UIImage(named: "discussions-thumb-up")?.withRenderingMode(.alwaysTemplate)
        imageButton.titleInsets = self.appearance.voteLikeButtonTitleInsets
        imageButton.addTarget(self, action: #selector(self.likeImageButtonClicked), for: .touchUpInside)
        return imageButton
    }()

    private lazy var dislikeImageButton: ImageButton = {
        let imageButton = ImageButton()
        imageButton.imageSize = self.appearance.voteImageSize
        imageButton.tintColor = self.appearance.voteImageNormalTintColor
        imageButton.font = self.appearance.voteButtonFont
        imageButton.title = "0"
        imageButton.image = UIImage(named: "discussions-thumb-down")?.withRenderingMode(.alwaysTemplate)
        imageButton.titleInsets = self.appearance.voteDislikeButtonTitleInsets
        imageButton.addTarget(self, action: #selector(self.dislikeImageButtonClicked), for: .touchUpInside)
        return imageButton
    }()

    private lazy var bottomControlsStackView: UIStackView = {
        let dateAndReplyStackView = UIStackView(arrangedSubviews: [self.dateLabel, self.replyButton])
        dateAndReplyStackView.axis = .horizontal
        dateAndReplyStackView.distribution = .fill
        dateAndReplyStackView.spacing = self.appearance.bottomControlsSubgroupSpacing
        dateAndReplyStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let votesStackView = UIStackView(arrangedSubviews: [self.likeImageButton, self.dislikeImageButton])
        votesStackView.axis = .horizontal
        votesStackView.distribution = .fill
        votesStackView.spacing = self.appearance.bottomControlsSubgroupSpacing * 2

        let containerStackView = UIStackView(arrangedSubviews: [dateAndReplyStackView, votesStackView])
        containerStackView.axis = .horizontal
        containerStackView.distribution = .equalSpacing
        containerStackView.spacing = self.appearance.bottomControlsSpacing

        return containerStackView
    }()

    // Dynamically position nameLabel on based on badges visibility
    private var nameLabelTopToBottomOfBadgesConstraint: Constraint?
    private var nameLabelTopToTopOfAvatarConstraint: Constraint?

    // Keeps track of web content text view height
    private var currentWebBasedTextViewHeight = Appearance().textContentWebBasedTextViewDefaultHeight
    private var currentText: String?

    private let htmlToAttributedStringConverter: HTMLToAttributedStringConverterProtocol

    var onReplyClick: (() -> Void)?
    var onLikeClick: (() -> Void)?
    var onDislikeClick: (() -> Void)?
    var onAvatarClick: (() -> Void)?
    var onLinkClick: ((URL) -> Void)?
    var onImageClick: ((URL) -> Void)?
    var onSolutionClick: (() -> Void)?
    // Content height updates callbacks
    var onContentLoaded: (() -> Void)?
    var onNewHeightUpdate: (() -> Void)?

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        self.htmlToAttributedStringConverter = HTMLToAttributedStringConverter(
            font: appearance.textContentTextLabelFont,
            tagTransformers: []
        )

        super.init(frame: frame)

        self.setupView()
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
            self.updateViewColor()
        }
    }

    // MARK: - Public API

    func configure(viewModel: DiscussionsCommentViewModel?) {
        guard let viewModel = viewModel else {
            return self.resetViews()
        }

        self.nameLabel.text = viewModel.username
        self.dateLabel.text = viewModel.formattedDate

        self.updateBadges(userRoleBadgeText: viewModel.userRoleBadgeText, isPinned: viewModel.isPinned)
        self.updateVotes(
            likesCount: viewModel.likesCount,
            dislikesCount: viewModel.dislikesCount,
            canVote: viewModel.canVote,
            voteValue: viewModel.voteValue
        )
        self.updateTextContent(text: viewModel.processedText, isWebViewSupportNeeded: viewModel.isWebViewSupportNeeded)

        if let url = viewModel.avatarImageURL {
            self.avatarImageView.set(with: url)
        }

        if let solution = viewModel.solution {
            self.solutionControl.update(state: .init(quizStatus: solution.status), title: solution.title)
            self.solutionContainerView.isHidden = false
        } else {
            self.solutionContainerView.isHidden = true
        }
    }

    func calculateContentHeight(maxPreferredWidth: CGFloat) -> CGFloat {
        let userInfoHeight = (self.badgesStackView.isHidden ? 0 : self.appearance.badgesStackViewHeight)
            + (self.badgesStackView.isHidden ? 0 : self.appearance.nameLabelInsets.top)
            + self.appearance.nameLabelHeight

        let solutionHeight = self.solutionContainerView.isHidden
            ? 0
            : self.appearance.solutionControlInsets.top + self.appearance.solutionControlHeight

        return self.appearance.avatarImageViewInsets.top
            + userInfoHeight
            + self.appearance.textContentContainerViewInsets.top
            + self.getTextContentHeight(maxPreferredWidth: maxPreferredWidth)
            + solutionHeight
            + self.appearance.bottomControlsInsets.top
            + self.appearance.bottomControlsHeight
            + self.appearance.bottomControlsInsets.bottom
    }

    // MARK: - Private API

    private func updateViewColor() {
        self.userRoleBadgeLabel.backgroundColor = self.isDarkInterfaceStyle
            ? self.appearance.badgeUserRoleDarkBackgroundColor
            : self.appearance.badgeUserRoleLightBackgroundColor

        self.isPinnedImageButton.backgroundColor = self.isDarkInterfaceStyle
            ? self.appearance.badgeIsPinnedDarkBackgroundColor
            : self.appearance.badgeIsPinnedLightBackgroundColor
    }

    private func resetViews() {
        self.nameLabel.text = nil
        self.dateLabel.text = nil
        self.avatarImageView.reset()
        self.updateBadges(userRoleBadgeText: nil, isPinned: false)
        self.updateVotes(likesCount: 0, dislikesCount: 0, canVote: false, voteValue: nil)
        self.updateTextContent(text: "", isWebViewSupportNeeded: false)
    }

    private func updateBadges(userRoleBadgeText: String?, isPinned: Bool) {
        self.userRoleBadgeLabel.text = userRoleBadgeText
        self.userRoleBadgeLabel.isHidden = userRoleBadgeText?.isEmpty ?? true

        self.isPinnedImageButton.isHidden = !isPinned

        self.badgesStackView.isHidden = self.userRoleBadgeLabel.isHidden && self.isPinnedImageButton.isHidden

        if self.badgesStackView.isHidden {
            self.nameLabelTopToBottomOfBadgesConstraint?.deactivate()
            self.nameLabelTopToTopOfAvatarConstraint?.activate()
        } else {
            self.nameLabelTopToTopOfAvatarConstraint?.deactivate()
            self.nameLabelTopToBottomOfBadgesConstraint?.activate()
        }
    }

    private func updateVotes(likesCount: Int, dislikesCount: Int, canVote: Bool, voteValue: VoteValue?) {
        self.likeImageButton.title = "\(likesCount)"
        self.dislikeImageButton.title = "\(dislikesCount)"

        if let voteValue = voteValue {
            if voteValue == .epic {
                self.likeImageButton.tintColor = self.appearance.voteImageFilledTintColor
                self.dislikeImageButton.tintColor = self.appearance.voteImageNormalTintColor
            } else {
                self.dislikeImageButton.tintColor = self.appearance.voteImageFilledTintColor
                self.likeImageButton.tintColor = self.appearance.voteImageNormalTintColor
            }
        } else if canVote {
            self.likeImageButton.tintColor = self.appearance.voteImageNormalTintColor
            self.dislikeImageButton.tintColor = self.appearance.voteImageNormalTintColor
        } else {
            self.likeImageButton.tintColor = self.appearance.voteImageDisabledTintColor
            self.dislikeImageButton.tintColor = self.appearance.voteImageDisabledTintColor
        }

        self.likeImageButton.isEnabled = canVote
        self.dislikeImageButton.isEnabled = canVote
    }

    private func updateTextContent(text: String, isWebViewSupportNeeded: Bool) {
        self.currentText = text

        if isWebViewSupportNeeded {
            self.textContentTextLabel.attributedText = nil
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
            self.textContentTextLabel.attributedText = self.htmlToAttributedStringConverter.convertToAttributedText(
                htmlString: text.trimmed()
            ) as? AttributedText
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
    private func replyButtonClicked() {
        self.onReplyClick?()
    }

    @objc
    private func likeImageButtonClicked() {
        self.onLikeClick?()
    }

    @objc
    private func dislikeImageButtonClicked() {
        self.onDislikeClick?()
    }

    @objc
    private func avatarButtonClicked() {
        self.onAvatarClick?()
    }

    @objc
    private func solutionControlClicked() {
        self.onSolutionClick?()
    }
}

// MARK: - DiscussionsCellView: ProgrammaticallyInitializableViewProtocol -

extension DiscussionsCellView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateViewColor()
    }

    func addSubviews() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.avatarOverlayButton)
        self.addSubview(self.badgesStackView)
        self.addSubview(self.nameLabel)
        self.addSubview(self.textContentStackView)
        self.solutionContainerView.addSubview(self.solutionControl)
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

        self.badgesStackView.translatesAutoresizingMaskIntoConstraints = false
        self.badgesStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.badgesStackViewInsets.top)
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.badgesStackViewInsets.left)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.badgesStackViewInsets.right)
            make.height.equalTo(self.appearance.badgesStackViewHeight)
        }

        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.nameLabel.snp.makeConstraints { make in
            self.nameLabelTopToBottomOfBadgesConstraint = make
                .top
                .equalTo(self.badgesStackView.snp.bottom)
                .offset(self.appearance.nameLabelInsets.top)
                .constraint
            self.nameLabelTopToBottomOfBadgesConstraint?.deactivate()

            self.nameLabelTopToTopOfAvatarConstraint = make.top.equalTo(self.avatarImageView.snp.top).constraint

            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.nameLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.nameLabelInsets.right)
            make.height.equalTo(self.appearance.nameLabelHeight)
        }

        self.textContentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.textContentStackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.textContentStackView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.textContentStackView.snp.makeConstraints { make in
            make.top
                .greaterThanOrEqualTo(self.nameLabel.snp.bottom)
                .offset(self.appearance.textContentContainerViewInsets.top)
            make.leading.equalTo(self.nameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-self.appearance.textContentContainerViewInsets.right)
            make.bottom
                .equalTo(self.bottomControlsStackView.snp.top)
                .offset(-self.appearance.textContentContainerViewInsets.bottom)
        }

        self.solutionControl.translatesAutoresizingMaskIntoConstraints = false
        self.solutionControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.solutionControlInsets.top)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.solutionControlHeight)
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

// MARK: - DiscussionsCellView: ProcessedContentWebViewDelegate -

extension DiscussionsCellView: ProcessedContentWebViewDelegate {
    func processedContentTextViewDidLoadContent(_ view: ProcessedContentWebView) {
        if self.textContentWebBasedTextView.isHidden {
            return
        }

        self.currentWebBasedTextViewHeight = CGFloat(self.textContentWebBasedTextView.currentWebViewHeight)
        self.textContentWebBasedTextView.alpha = 1
        self.onContentLoaded?()
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didReportNewHeight height: Int) {
        if self.textContentWebBasedTextView.isHidden {
            return
        }

        let newHeight = CGFloat(height)
        if newHeight != self.currentWebBasedTextViewHeight {
            self.currentWebBasedTextViewHeight = newHeight
            self.onNewHeightUpdate?()
        }
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didOpenImageURL url: URL) {
        self.onImageClick?(url)
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didOpenImage image: UIImage) {}

    func processedContentTextView(_ view: ProcessedContentWebView, didOpenLink url: URL) {
        self.onLinkClick?(url)
    }
}
