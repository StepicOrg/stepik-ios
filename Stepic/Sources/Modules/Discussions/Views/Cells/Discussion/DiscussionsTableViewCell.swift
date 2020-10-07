import SnapKit
import UIKit

// MARK: Appearance -

extension DiscussionsTableViewCell {
    enum Appearance {
        static let separatorColor = UIColor.stepikSeparator

        static let selectedBackgroundColor = UIColor.dynamic(
            light: .stepikExtraLightVioletFixed,
            dark: .stepikSecondaryBackground
        )
        static let defaultBackgroundColor = UIColor.stepikBackground

        static let leadingOffsetDiscussion: CGFloat = 0
        static let leadingOffsetReply: CGFloat = 18
        static let leadingOffsetCellView: CGFloat = DiscussionsCellView.Appearance().avatarImageViewInsets.left
    }
}

// MARK: - DiscussionsTableViewCell: UITableViewCell, Reusable -

final class DiscussionsTableViewCell: UITableViewCell, Reusable {
    private lazy var cellView: DiscussionsCellView = {
        let cellView = DiscussionsCellView()
        cellView.onNewHeightUpdate = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            let newHeight = strongSelf.calculateCellHeight(maxPreferredWidth: strongSelf.cellView.bounds.width)
            strongSelf.onNewHeightUpdate?(newHeight)
        }
        return cellView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.separatorColor
        return view
    }()

    // Dynamic cell/separator leading offset
    private var cellViewLeadingConstraint: Constraint?
    private var separatorLeadingConstraint: Constraint?

    // Dynamic separator height
    private var separatorHeightConstraint: Constraint?
    private var separatorStyle: ViewModel.SeparatorStyle = .small

    // Highlight background if open from deeplink.
    private var shouldHighlightBackground = false {
        didSet {
            self.backgroundColor = self.getBackgroundColor()
        }
    }

    var onReplyClick: (() -> Void)? {
        get {
            self.cellView.onReplyClick
        }
        set {
            self.cellView.onReplyClick = newValue
        }
    }
    var onLikeClick: (() -> Void)? {
        get {
            self.cellView.onLikeClick
        }
        set {
            self.cellView.onLikeClick = newValue
        }
    }
    var onDislikeClick: (() -> Void)? {
        get {
            self.cellView.onDislikeClick
        }
        set {
            self.cellView.onDislikeClick = newValue
        }
    }
    var onAvatarClick: (() -> Void)? {
        get {
            self.cellView.onAvatarClick
        }
        set {
            self.cellView.onAvatarClick = newValue
        }
    }
    var onLinkClick: ((URL) -> Void)? {
        get {
            self.cellView.onLinkClick
        }
        set {
            self.cellView.onLinkClick = newValue
        }
    }
    var onImageClick: ((URL) -> Void)? {
        get {
            self.cellView.onImageClick
        }
        set {
            self.cellView.onImageClick = newValue
        }
    }
    var onSolutionClick: (() -> Void)? {
        get {
            self.cellView.onSolutionClick
        }
        set {
            self.cellView.onSolutionClick = newValue
        }
    }
    // Content callbacks
    var onContentLoaded: (() -> Void)? {
        get {
            self.cellView.onContentLoaded
        }
        set {
            self.cellView.onContentLoaded = newValue
        }
    }
    var onNewHeightUpdate: ((CGFloat) -> Void)?

    override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()

        if self.cellView.superview == nil {
            self.setupSubview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetViews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.backgroundColor = self.getBackgroundColor()
        }
    }

    // MARK: - Public API

    func configure(viewModel: ViewModel) {
        self.updateLeadingOffsets(
            commentType: viewModel.commentType,
            hasReplies: viewModel.comment.hasReplies,
            separatorFollowsDepth: viewModel.separatorFollowsDepth
        )
        self.updateSeparator(newStyle: viewModel.separatorStyle)

        self.shouldHighlightBackground = viewModel.isSelected
        self.cellView.configure(viewModel: viewModel.comment)

        if case .text = viewModel.comment.processedContent {
            self.onContentLoaded?()
        }
    }

    func calculateCellHeight(maxPreferredWidth: CGFloat) -> CGFloat {
        let leadingOffset = self.cellViewLeadingConstraint?.layoutConstraints.first?.constant ?? 0

        let cellViewWidth = maxPreferredWidth - leadingOffset
        let cellViewHeight = self.cellView.calculateContentHeight(maxPreferredWidth: cellViewWidth)

        return cellViewHeight + self.separatorStyle.height
    }

    // MARK: - Private API

    private func setupSubview() {
        self.contentView.addSubview(self.cellView)
        self.contentView.addSubview(self.separatorView)

        self.clipsToBounds = true
        self.contentView.clipsToBounds = true

        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        self.cellView.snp.makeConstraints { make in
            self.cellViewLeadingConstraint = make.leading
                .equalToSuperview()
                .offset(Appearance.leadingOffsetDiscussion)
                .constraint
            make.top.trailing.equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            self.separatorLeadingConstraint = make.leading
                .equalToSuperview()
                .offset(Appearance.leadingOffsetDiscussion)
                .constraint
            make.top.equalTo(self.cellView.snp.bottom)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
            self.separatorHeightConstraint = make.height.equalTo(self.separatorStyle.height).constraint
        }
    }

    private func resetViews() {
        self.updateLeadingOffsets(commentType: .discussion, hasReplies: false, separatorFollowsDepth: false)
        self.updateSeparator(newStyle: .small)
        self.shouldHighlightBackground = false
        self.cellView.configure(viewModel: nil)
    }

    private func updateLeadingOffsets(
        commentType: ViewModel.CommentType,
        hasReplies: Bool,
        separatorFollowsDepth: Bool
    ) {
        let cellViewLeadingOffset = commentType == .discussion
            ? Appearance.leadingOffsetDiscussion
            : Appearance.leadingOffsetReply
        self.cellViewLeadingConstraint?.update(offset: cellViewLeadingOffset)

        let separatorLeadingOffset: CGFloat = {
            if commentType == .discussion && hasReplies {
                return Appearance.leadingOffsetReply + Appearance.leadingOffsetCellView
            }
            return separatorFollowsDepth
                ? (cellViewLeadingOffset + Appearance.leadingOffsetCellView)
                : Appearance.leadingOffsetDiscussion
        }()

        self.separatorLeadingConstraint?.update(offset: separatorLeadingOffset)
    }

    private func updateSeparator(newStyle style: ViewModel.SeparatorStyle) {
        self.separatorStyle = style
        self.separatorHeightConstraint?.update(offset: style.height)
        self.separatorView.isHidden = style == .none
    }

    private func getBackgroundColor() -> UIColor {
        if self.shouldHighlightBackground {
            return Appearance.selectedBackgroundColor
        } else {
            return Appearance.defaultBackgroundColor
        }
    }

    // MARK: - Types

    struct ViewModel {
        let comment: DiscussionsCommentViewModel
        let commentType: CommentType
        let isSelected: Bool
        let separatorStyle: SeparatorStyle
        let separatorFollowsDepth: Bool

        enum CommentType {
            case discussion
            case reply
        }

        enum SeparatorStyle {
            case small
            case large
            case none

            var height: CGFloat {
                switch self {
                case .small:
                    return 1.0 / UIScreen.main.scale
                case .large:
                    return 8.0 / UIScreen.main.scale
                case .none:
                    return 0.0
                }
            }
        }
    }
}
