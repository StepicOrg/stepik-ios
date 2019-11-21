import SnapKit
import UIKit

extension DiscussionsTableViewCell {
    enum Appearance {
        static let separatorColor = UIColor(hex: 0xE7E7E7)

        static let selectedBackgroundColor = UIColor(hex: 0xE9EBFA)
        static let defaultBackgroundColor = UIColor.white

        static let leadingSpaceDiscussion: CGFloat = 0
        static let leadingSpaceReply: CGFloat = 18
    }
}

// MARK: - DiscussionsTableViewCell: UITableViewCell, Reusable -

final class DiscussionsTableViewCell: UITableViewCell, Reusable {
    private lazy var cellView: DiscussionsCellView = {
        let cellView = DiscussionsCellView()
        cellView.onDotsMenuClick = { [weak self] in
            self?.onDotsMenuClick?()
        }
        cellView.onReplyClick = { [weak self] in
            self?.onReplyClick?()
        }
        cellView.onLikeClick = { [weak self] in
            self?.onLikeClick?()
        }
        cellView.onDislikeClick = { [weak self] in
            self?.onDislikeClick?()
        }
        cellView.onAvatarClick = { [weak self] in
            self?.onAvatarClick?()
        }
        cellView.onLinkClick = { [weak self] url in
            self?.onLinkClick?(url)
        }
        cellView.onContentLoaded = { [weak self] in
            self?.onContentLoaded?()
        }
        cellView.onNewHeightUpdate = { [weak self] in
            if let strongSelf = self {
                strongSelf.onNewHeightUpdate?(
                    strongSelf.calculateCellHeight(maxPreferredWidth: strongSelf.cellView.bounds.width)
                )
            }
        }
        return cellView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.separatorColor
        return view
    }()

    // Dynamic cell/separator leading space
    private var cellLeadingConstraint: Constraint?
    private var separatorLeadingConstraint: Constraint?

    // Dynamic separator height
    private var separatorHeightConstraint: Constraint?
    private var separatorType: ViewModel.SeparatorType = .small

    var onDotsMenuClick: (() -> Void)?
    var onReplyClick: (() -> Void)?
    var onLikeClick: (() -> Void)?
    var onDislikeClick: (() -> Void)?
    var onAvatarClick: (() -> Void)?
    var onLinkClick: ((URL) -> Void)?
    var onContentLoaded: (() -> Void)?
    var onNewHeightUpdate: ((CGFloat) -> Void)?

    override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()

        if self.cellView.superview == nil {
            self.setupSubview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.configure(optionalViewModel: nil)
    }

    // MARK: - Public API

    func configure(viewModel: ViewModel) {
        self.configure(optionalViewModel: viewModel)
    }

    func calculateCellHeight(maxPreferredWidth: CGFloat) -> CGFloat {
        let leadingInset = self.cellLeadingConstraint?.layoutConstraints.first?.constant ?? 0

        let cellViewWidth = maxPreferredWidth - leadingInset
        let cellViewHeight = self.cellView.calculateContentHeight(maxPreferredWidth: cellViewWidth)

        return cellViewHeight + self.separatorType.height
    }

    // MARK: - Private API

    private func setupSubview() {
        self.contentView.addSubview(self.cellView)
        self.contentView.addSubview(self.separatorView)

        self.clipsToBounds = true
        self.contentView.clipsToBounds = true

        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        self.cellView.snp.makeConstraints { make in
            self.cellLeadingConstraint = make.leading
                .equalToSuperview()
                .offset(Appearance.leadingSpaceDiscussion)
                .constraint
            make.top.trailing.equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            self.separatorLeadingConstraint = make.leading
                .equalToSuperview()
                .offset(Appearance.leadingSpaceDiscussion)
                .constraint
            make.top.equalTo(self.cellView.snp.bottom)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
            self.separatorHeightConstraint = make.height.equalTo(self.separatorType.height).constraint
        }
    }

    private func configure(optionalViewModel: ViewModel?) {
        if let viewModel = optionalViewModel {
            self.backgroundColor = viewModel.isSelected
                ? Appearance.selectedBackgroundColor
                : Appearance.defaultBackgroundColor
            self.updateLeadingInsets(
                commentType: viewModel.commentType,
                separatorFollowsDepth: viewModel.separatorFollowsDepth
            )
            self.updateSeparatorType(separatorType: viewModel.separatorType)
            self.cellView.configure(viewModel: viewModel.comment)
        } else {
            self.backgroundColor = Appearance.defaultBackgroundColor
            self.updateLeadingInsets(commentType: .discussion, separatorFollowsDepth: false)
            self.updateSeparatorType(separatorType: .small)
            self.cellView.configure(viewModel: nil)
        }
    }

    private func updateLeadingInsets(commentType: ViewModel.CommentType, separatorFollowsDepth: Bool) {
        let leadingSpaceValue = commentType == .discussion
            ? Appearance.leadingSpaceDiscussion
            : Appearance.leadingSpaceReply
        self.cellLeadingConstraint?.update(offset: leadingSpaceValue)
        self.separatorLeadingConstraint?.update(
            offset: separatorFollowsDepth ? leadingSpaceValue : Appearance.leadingSpaceDiscussion
        )
    }

    private func updateSeparatorType(separatorType: ViewModel.SeparatorType) {
        if separatorType != self.separatorType {
            self.separatorType = separatorType
            self.separatorHeightConstraint?.update(offset: self.separatorType.height)
        }

        self.separatorView.isHidden = self.separatorType == .none
    }

    // MARK: - Types

    struct ViewModel {
        let comment: DiscussionsCommentViewModel
        let commentType: CommentType
        let separatorType: SeparatorType
        let separatorFollowsDepth: Bool
        let isSelected: Bool

        enum CommentType {
            case discussion
            case reply
        }

        enum SeparatorType {
            case small
            case large
            case none

            var height: CGFloat {
                switch self {
                case .small:
                    return 0.5
                case .large:
                    return 4.0
                case .none:
                    return 0.0
                }
            }
        }
    }
}
