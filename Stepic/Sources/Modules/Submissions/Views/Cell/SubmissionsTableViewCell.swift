import SnapKit
import UIKit

final class SubmissionsTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let separatorHeight: CGFloat = 4
        static let separatorBackgroundColor = UIColor.stepikOverlayOnSurfaceBackground
    }

    private lazy var cellView = SubmissionsCellView()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.separatorBackgroundColor
        return view
    }()

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

    var onReviewClick: (() -> Void)? {
        get {
            self.cellView.onReviewClick
        }
        set {
            self.cellView.onReviewClick = newValue
        }
    }

    var onSelectSubmissionClick: (() -> Void)? {
        get {
            self.cellView.onSelectSubmissionClick
        }
        set {
            self.cellView.onSelectSubmissionClick = newValue
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
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
            make.height.equalTo(Appearance.separatorHeight)
        }
    }
}
