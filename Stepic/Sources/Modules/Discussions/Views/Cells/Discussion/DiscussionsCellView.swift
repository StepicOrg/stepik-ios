import Atributika
import SnapKit
import UIKit

// MARK: Appearance -

extension DiscussionsCellView {
    struct Appearance {
        let avatarImageViewInsets = LayoutInsets(top: 16, left: 16)
        let avatarImageViewSize = CGSize(width: 36, height: 36)
        let avatarImageViewCornerRadius: CGFloat = 4.0

        let badgesViewHeight: CGFloat = 20
        let badgesViewInsets = LayoutInsets(top: 16, left: 16, right: 16)

        let nameLabelInsets = LayoutInsets(top: 8, left: 16, right: 16)
        let nameLabelFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let nameLabelTextColor = UIColor.stepikSystemPrimaryText
        let nameLabelHeight: CGFloat = 18

        let moreButtonSize = CGSize(width: 26, height: 26)
        let moreButtonTintColor = UIColor.stepikSystemSecondaryText
        let moreButtonInsets = LayoutInsets(right: 16)

        let secondaryTextColor = UIColor.dynamic(
            light: UIColor.black.withAlphaComponent(0.6),
            dark: .stepikSystemSecondaryText
        )
        let processedContentViewLabelFont = UIFont.systemFont(ofSize: 15)
        let textContentStackViewInsets = LayoutInsets(top: 8, bottom: 16, right: 16)

        let solutionControlHeight = DiscussionsSolutionControl.Appearance.height
        let solutionControlInsets = LayoutInsets(top: 8)

        let bottomControlsViewInsets = LayoutInsets(left: 16, bottom: 16, right: 16)
        let bottomControlsViewHeight: CGFloat = 20
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

    private lazy var moreButton: UIButton = {
        let image = UIImage(named: "horizontal-dots-icon")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = self.appearance.moreButtonTintColor
        button.addTarget(self, action: #selector(self.moreButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var processedContentView: ProcessedContentView = {
        let appearance = ProcessedContentView.Appearance(
            labelFont: self.appearance.processedContentViewLabelFont,
            labelTextColor: self.appearance.secondaryTextColor,
            activityIndicatorViewStyle: .stepikGray,
            activityIndicatorViewColor: nil,
            insets: LayoutInsets(insets: .zero),
            backgroundColor: .clear
        )

        let processedContentView = ProcessedContentView(
            frame: .zero,
            appearance: appearance,
            contentProcessor: ContentProcessor(),
            htmlToAttributedStringConverter: HTMLToAttributedStringConverter(
                font: self.appearance.processedContentViewLabelFont,
                tagTransformers: [.brTransformer]
            )
        )
        processedContentView.delegate = self

        return processedContentView
    }()

    private lazy var textContentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var solutionControl: DiscussionsSolutionControl = {
        let control = DiscussionsSolutionControl()
        control.addTarget(self, action: #selector(self.solutionControlClicked), for: .touchUpInside)
        return control
    }()

    private lazy var solutionContainerView = UIView()

    private lazy var bottomControlsView = DiscussionsBottomControlsView(
        appearance: .init(dateLabelTextColor: self.appearance.secondaryTextColor)
    )

    // Dynamically position nameLabel on based on badges visibility
    private var nameLabelTopToBottomOfBadgesConstraint: Constraint?
    private var nameLabelTopToTopOfAvatarConstraint: Constraint?

    private var moreButtonCenterYToCenterYOfBadges: Constraint?
    private var moreButtonCenterYToCenterYOfNameLabel: Constraint?

    var onReplyClick: (() -> Void)? {
        get {
            self.bottomControlsView.onReplyClick
        }
        set {
            self.bottomControlsView.onReplyClick = newValue
        }
    }

    var onLikeClick: (() -> Void)? {
        get {
            self.bottomControlsView.onLikeClick
        }
        set {
            self.bottomControlsView.onLikeClick = newValue
        }
    }

    var onDislikeClick: (() -> Void)? {
        get {
            self.bottomControlsView.onDislikeClick
        }
        set {
            self.bottomControlsView.onDislikeClick = newValue
        }
    }

    var onAvatarClick: (() -> Void)?
    var onMoreClick: (() -> Void)?
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

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let userInfoHeight = (self.badgesView.isHidden ? 0 : self.appearance.badgesViewHeight)
            + (self.badgesView.isHidden ? 0 : self.appearance.nameLabelInsets.top)
            + self.appearance.nameLabelHeight

        let solutionHeight = self.solutionContainerView.isHidden
            ? 0
            : self.appearance.solutionControlInsets.top + self.appearance.solutionControlHeight

        let textContentHeight: CGFloat = {
            let textContentWidth = size.width
                - self.appearance.avatarImageViewInsets.left
                - self.appearance.avatarImageViewSize.width
                - self.appearance.nameLabelInsets.left
                - self.appearance.textContentStackViewInsets.right

            let specifiedSize = CGSize(width: textContentWidth, height: size.height)
            let bestFitsSize = self.processedContentView.sizeThatFits(specifiedSize)

            return bestFitsSize.height
        }()

        let height = self.appearance.avatarImageViewInsets.top
            + userInfoHeight
            + self.appearance.textContentStackViewInsets.top
            + textContentHeight
            + solutionHeight
            + self.appearance.textContentStackViewInsets.bottom
            + self.appearance.bottomControlsViewHeight
            + self.appearance.bottomControlsViewInsets.bottom

        return CGSize(width: UIView.noIntrinsicMetric, height: ceil(height))
    }

    // MARK: - Public API

    func configure(viewModel: DiscussionsCommentViewModel?) {
        guard let viewModel = viewModel else {
            return self.resetViews()
        }

        if let url = viewModel.avatarImageURL {
            self.avatarImageView.set(with: url)
        }

        self.updateBadges(userRoleBadgeText: viewModel.userRoleBadgeText, isPinned: viewModel.isPinned)

        if self.badgesView.isHidden {
            self.moreButtonCenterYToCenterYOfNameLabel?.activate()
            self.moreButtonCenterYToCenterYOfBadges?.deactivate()
        } else {
            self.moreButtonCenterYToCenterYOfNameLabel?.deactivate()
            self.moreButtonCenterYToCenterYOfBadges?.activate()
        }

        self.nameLabel.text = viewModel.username

        self.processedContentView.processedContent = viewModel.processedContent

        self.bottomControlsView.configure(
            .init(
                formattedDateText: viewModel.formattedDate,
                likesCount: viewModel.likesCount,
                dislikesCount: viewModel.dislikesCount,
                canVote: viewModel.canVote,
                voteValue: viewModel.voteValue
            )
        )

        if let solution = viewModel.solution {
            self.solutionControl.update(state: .init(quizStatus: solution.status), title: solution.title)
            self.solutionContainerView.isHidden = false
        } else {
            self.solutionContainerView.isHidden = true
        }
    }

    // MARK: - Private API

    private func resetViews() {
        self.nameLabel.text = nil
        self.avatarImageView.reset()
        self.updateBadges(userRoleBadgeText: nil, isPinned: false)
        self.bottomControlsView.configure(
            .init(formattedDateText: nil, likesCount: 0, dislikesCount: 0, canVote: false, voteValue: nil)
        )
        self.processedContentView.setText(nil)
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

    // MARK: Actions

    @objc
    private func avatarButtonClicked() {
        self.onAvatarClick?()
    }

    @objc
    private func moreButtonClicked() {
        self.onMoreClick?()
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
        self.solutionContainerView.isHidden = true
    }

    func addSubviews() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.avatarOverlayButton)
        self.addSubview(self.badgesView)
        self.addSubview(self.nameLabel)
        self.addSubview(self.moreButton)

        self.addSubview(self.textContentStackView)
        self.textContentStackView.addArrangedSubview(self.processedContentView)
        self.textContentStackView.addArrangedSubview(self.solutionContainerView)
        self.solutionContainerView.addSubview(self.solutionControl)

        self.addSubview(self.bottomControlsView)
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
            make.trailing.lessThanOrEqualTo(self.moreButton.snp.leading).offset(-self.appearance.badgesViewInsets.right)
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
            make.trailing.equalTo(self.moreButton.snp.leading).offset(-self.appearance.nameLabelInsets.right)
            make.height.equalTo(self.appearance.nameLabelHeight)
        }

        self.moreButton.translatesAutoresizingMaskIntoConstraints = false
        self.moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.moreButtonInsets.right)
            make.size.equalTo(self.appearance.moreButtonSize)

            self.moreButtonCenterYToCenterYOfBadges = make.centerY.equalTo(self.badgesView.snp.centerY).constraint
            self.moreButtonCenterYToCenterYOfNameLabel = make.centerY.equalTo(self.nameLabel.snp.centerY).constraint

            self.moreButtonCenterYToCenterYOfBadges?.deactivate()
            self.moreButtonCenterYToCenterYOfNameLabel?.deactivate()
        }

        self.textContentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.textContentStackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.textContentStackView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.textContentStackView.snp.makeConstraints { make in
            make.top
                .greaterThanOrEqualTo(self.nameLabel.snp.bottom)
                .offset(self.appearance.textContentStackViewInsets.top)
            make.leading.equalTo(self.nameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-self.appearance.textContentStackViewInsets.right)
            make.bottom
                .lessThanOrEqualTo(self.bottomControlsView.snp.top)
                .offset(-self.appearance.textContentStackViewInsets.bottom)
        }

        self.solutionControl.translatesAutoresizingMaskIntoConstraints = false
        self.solutionControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.solutionControlInsets.top)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.solutionControlHeight)
        }

        self.bottomControlsView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomControlsView.snp.makeConstraints { make in
            make.leading
                .equalTo(self.avatarImageView.snp.trailing)
                .offset(self.appearance.bottomControlsViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.bottomControlsViewInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.bottomControlsViewInsets.bottom)
            make.height.equalTo(self.appearance.bottomControlsViewHeight)
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
