import SnapKit
import UIKit

extension NewDiscussionsTableViewCell {
    enum Appearance {
        static let separatorColor = UIColor(hex: 0xe7e7e7)

        static let leadingSpaceDiscussion: CGFloat = 0
        static let leadingSpaceReply: CGFloat = 40
    }
}

final class NewDiscussionsTableViewCell: UITableViewCell, Reusable {
    private lazy var cellView: NewDiscussionsCellView = {
        let cellView = NewDiscussionsCellView()
        cellView.onReplyClick = { [weak self] in
            self?.onReplyClick?()
        }
        cellView.onLikeClick = { [weak self] in
            self?.onLikeClick?()
        }
        cellView.onDislikeClick = { [weak self] in
            self?.onDislikeClick?()
        }
        cellView.onContentLoaded = { [weak self] in
            self?.onContentLoaded?()
        }
        cellView.onNewHeightUpdate = { [weak self] in
            if let strongSelf = self {
                strongSelf.onNewHeightUpdate?(strongSelf.contentHeight)
            }
        }
        return cellView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.separatorColor
        return view
    }()

    // Use computer property because intrinsicContentSize works not well
    var contentHeight: CGFloat {
        return self.cellView.contentHeight + self.separatorType.height
    }

    // Dynamic cell/separator leading space
    private var cellLeadingConstraint: Constraint?
    private var separatorLeadingConstraint: Constraint?

    // Dynamic separator height
    private var separatorHeightConstraint: Constraint?
    private var separatorType: ViewModel.SeparatorType = .small

    var onReplyClick: (() -> Void)?
    var onLikeClick: (() -> Void)?
    var onDislikeClick: (() -> Void)?
    // Dynamic content callbacks
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

    func configure(viewModel: ViewModel) {
        self.configure(optionalViewModel: viewModel)
    }

    // MARK: - Private API

    private func setupSubview() {
        self.contentView.addSubview(self.cellView)
        self.contentView.addSubview(self.separatorView)

        self.clipsToBounds = true
        self.contentView.clipsToBounds = true

        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        self.cellView.snp.makeConstraints { make in
            self.cellLeadingConstraint = make.leading.equalToSuperview()
                .offset(Appearance.leadingSpaceDiscussion).constraint
            make.top.trailing.equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            self.separatorLeadingConstraint = make.leading.equalToSuperview()
                .offset(Appearance.leadingSpaceDiscussion).constraint
            make.top.equalTo(self.cellView.snp.bottom)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
            self.separatorHeightConstraint = make.height.equalTo(self.separatorType.height).constraint
        }
    }

    private func configure(optionalViewModel: ViewModel?) {
        if let viewModel = optionalViewModel {
            self.updateLeadingInsets(
                newCommentType: viewModel.commentType,
                separatorFollowsDepth: viewModel.separatorFollowsDepth
            )
            self.updateSeparatorType(newSeparatorType: viewModel.separatorType)
            self.cellView.configure(viewModel: viewModel.comment)
        } else {
            self.updateLeadingInsets(newCommentType: .discussion, separatorFollowsDepth: false)
            self.updateSeparatorType(newSeparatorType: .small)
            self.cellView.configure(viewModel: nil)
        }
    }

    private func updateLeadingInsets(newCommentType: ViewModel.CommentType, separatorFollowsDepth: Bool) {
        let leadingSpaceValue = newCommentType == .discussion
            ? Appearance.leadingSpaceDiscussion
            : Appearance.leadingSpaceReply
        self.cellLeadingConstraint?.update(offset: leadingSpaceValue)
        self.separatorLeadingConstraint?.update(
            offset: separatorFollowsDepth ? leadingSpaceValue : Appearance.leadingSpaceDiscussion
        )
    }

    private func updateSeparatorType(newSeparatorType: ViewModel.SeparatorType) {
        if newSeparatorType != self.separatorType {
            self.separatorType = newSeparatorType
            self.separatorHeightConstraint?.update(offset: self.separatorType.height)
        }

        self.separatorView.isHidden = self.separatorType == .none
    }

    // MARK: - Types

    struct ViewModel {
        let comment: NewDiscussionsCommentViewModel
        let commentType: CommentType
        let separatorType: SeparatorType
        let separatorFollowsDepth: Bool

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
