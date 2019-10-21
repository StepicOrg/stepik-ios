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
    private var leadingSpaceValue: CGFloat = Appearance.leadingSpaceDiscussion

    // Dynamic separator height
    private var separatorHeightConstraint: Constraint?
    private var separatorType: ViewModel.SeparatorType = .small

    var onReplyClick: (() -> Void)?

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
            self.cellLeadingConstraint = make.leading.equalToSuperview().offset(self.leadingSpaceValue).constraint
            make.top.trailing.equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            self.separatorLeadingConstraint = make.leading.equalToSuperview().offset(self.leadingSpaceValue).constraint
            make.top.equalTo(self.cellView.snp.bottom)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
            self.separatorHeightConstraint = make.height.equalTo(self.separatorType.height).constraint
        }
    }

    private func configure(optionalViewModel: ViewModel?) {
        if let viewModel = optionalViewModel {
            self.updateCommentType(newCommentType: viewModel.commentType)
            self.updateSeparatorType(newSeparatorType: viewModel.separatorType)
            self.cellView.configure(viewModel: viewModel.comment)
        } else {
            self.updateCommentType(newCommentType: .discussion)
            self.updateSeparatorType(newSeparatorType: .small)
            self.cellView.configure(viewModel: nil)
        }
    }

    private func updateCommentType(newCommentType: ViewModel.CommentType) {
        let newLeadingSpace = newCommentType == .discussion
            ? Appearance.leadingSpaceDiscussion
            : Appearance.leadingSpaceReply
        if newLeadingSpace != self.leadingSpaceValue {
            self.leadingSpaceValue = newLeadingSpace
            self.cellLeadingConstraint?.update(offset: self.leadingSpaceValue)
            self.separatorLeadingConstraint?.update(offset: self.leadingSpaceValue)
        }
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
