import SnapKit
import UIKit

final class SubmissionsTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let separatorLeadingOffset: CGFloat = 16
    }

    enum SeparatorIndentationStyle {
        case indented
        case edgeToEdge

        fileprivate var offset: CGFloat {
            switch self {
            case .indented:
                return Appearance.separatorLeadingOffset
            case .edgeToEdge:
                return 0
            }
        }
    }

    private lazy var cellView = SubmissionsCellView()

    private lazy var separatorView = SeparatorView()
    private var separatorLeadingConstraint: Constraint?

    var separatorIndentationStyle: SeparatorIndentationStyle = .indented {
        didSet {
            self.separatorLeadingConstraint?.update(offset: self.separatorIndentationStyle.offset)
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

    var onMoreClick: (() -> Void)? {
        get {
            self.cellView.onMoreClick
        }
        set {
            self.cellView.onMoreClick = newValue
        }
    }

    var moreActionAnchorView: UIView { self.cellView.moreActionAnchorView }

    override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()

        if self.cellView.superview == nil {
            self.setupSubview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellView.configure(viewModel: nil)
    }

    func configure(viewModel: SubmissionViewModel) {
        self.cellView.configure(viewModel: viewModel)
    }

    private func setupSubview() {
        self.contentView.addSubview(self.cellView)
        self.contentView.addSubview(self.separatorView)

        self.clipsToBounds = true
        self.contentView.clipsToBounds = true

        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        self.cellView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.top.equalTo(self.cellView.snp.bottom)
            self.separatorLeadingConstraint = make.leading
                .equalToSuperview()
                .offset(self.separatorIndentationStyle.offset)
                .constraint
            make.bottom.equalToSuperview().priority(999)
            make.trailing.equalToSuperview()
            make.height.equalTo(self.separatorView.intrinsicContentSize.height)
        }
    }
}
