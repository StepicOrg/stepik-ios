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

        let badgesViewHeight: CGFloat = 20
        let badgesViewInsets = LayoutInsets(top: 16, left: 16, right: 16)

        let nameLabelInsets = LayoutInsets(top: 8, left: 16, right: 16)
        let nameLabelFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let nameLabelTextColor = UIColor.stepikPrimaryText
        let nameLabelHeight: CGFloat = 18

        let textContentContainerViewInsets = LayoutInsets(top: 8, bottom: 8, right: 16)
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


    private lazy var badgesView = DiscussionsBadgesView()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nameLabelFont
        label.textColor = self.appearance.nameLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var textContentView: ProcessedContentView = {
        let appearance = ProcessedContentView.Appearance(
            labelFont: self.appearance.textContentTextLabelFont,
            labelTextColor: self.appearance.textContentTextLabelTextColor,
            activityIndicatorViewStyle: .stepikGray,
            activityIndicatorViewColor: nil,
            insets: LayoutInsets(insets: .zero),
            backgroundColor: .clear
        )

        let contentProcessor = ContentProcessor(
            rules: ContentProcessor.defaultRules,
            injections: ContentProcessor.defaultInjections + [
                FontInjection(font: self.appearance.textContentTextLabelFont),
                TextColorInjection(dynamicColor: self.appearance.textContentTextLabelTextColor)
            ]
        )

        let processedContentView = ProcessedContentView(
            frame: .zero,
            appearance: appearance,
            contentProcessor: contentProcessor,
            htmlToAttributedStringConverter: HTMLToAttributedStringConverter(
                font: self.appearance.textContentTextLabelFont
            )
        )
        processedContentView.delegate = self

        return processedContentView
    }()

    private lazy var textContentStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.textContentView,
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

        self.nameLabel.text = viewModel.username
        self.dateLabel.text = viewModel.formattedDate

        self.updateBadges(userRoleBadgeText: viewModel.userRoleBadgeText, isPinned: viewModel.isPinned)
        self.updateVotes(
            likesCount: viewModel.likesCount,
            dislikesCount: viewModel.dislikesCount,
            canVote: viewModel.canVote,
            voteValue: viewModel.voteValue
        )
        self.textContentView.processedContent = viewModel.processedContent

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
        let userInfoHeight = (self.badgesView.isHidden ? 0 : self.appearance.badgesViewHeight)
            + (self.badgesView.isHidden ? 0 : self.appearance.nameLabelInsets.top)
            + self.appearance.nameLabelHeight

        let solutionHeight = self.solutionContainerView.isHidden
            ? 0
            : self.appearance.solutionControlInsets.top + self.appearance.solutionControlHeight

        return self.appearance.avatarImageViewInsets.top
            + userInfoHeight
            + self.appearance.textContentContainerViewInsets.top
            + self.textContentView.intrinsicContentSize.height
            + solutionHeight
            + self.appearance.bottomControlsInsets.top
            + self.appearance.bottomControlsHeight
            + self.appearance.bottomControlsInsets.bottom
    }

    // MARK: - Private API

    private func resetViews() {
        self.nameLabel.text = nil
        self.dateLabel.text = nil
        self.avatarImageView.reset()
        self.updateBadges(userRoleBadgeText: nil, isPinned: false)
        self.updateVotes(likesCount: 0, dislikesCount: 0, canVote: false, voteValue: nil)
        self.textContentView.setText(nil)
    }

    private func updateBadges(userRoleBadgeText: String?, isPinned: Bool) {
        self.badgesView.userRoleText = userRoleBadgeText
        self.badgesView.isPinned = isPinned

        self.badgesView.isHidden = self.badgesView.isAllBadgesHidden

        if self.badgesView.isHidden {
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
        self.badgesView.isHidden = true
    }

    func addSubviews() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.avatarOverlayButton)
        self.addSubview(self.badgesView)
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

        self.badgesView.translatesAutoresizingMaskIntoConstraints = false
        self.badgesView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.badgesViewInsets.top)
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.badgesViewInsets.left)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.badgesViewInsets.right)
            make.height.equalTo(self.appearance.badgesViewHeight)
        }

        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.nameLabel.snp.makeConstraints { make in
            self.nameLabelTopToBottomOfBadgesConstraint = make
                .top
                .equalTo(self.badgesView.snp.bottom)
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
                .lessThanOrEqualTo(self.bottomControlsStackView.snp.top)
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

extension DiscussionsCellView: ProcessedContentViewDelegate {
    func processedContentViewDidLoadContent(_ view: ProcessedContentView) {
        self.onContentLoaded?()
    }

    func processedContentView(_ view: ProcessedContentView, didReportNewHeight height: Int) {
        self.onNewHeightUpdate?()
    }

    func processedContentView(_ view: ProcessedContentView, didOpenImageURL url: URL) {
        self.onImageClick?(url)
    }

    func processedContentView(_ view: ProcessedContentView, didOpenLink url: URL) {
        self.onLinkClick?(url)
    }
}
