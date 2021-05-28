import SnapKit
import UIKit

extension UserCoursesReviewsLeavedReviewTableViewCell {
    enum Appearance {
        static let separatorHeight: CGFloat = 4
        static let separatorBackgroundColor = UIColor.onSurface.withAlphaComponent(0.04)
    }
}

final class UserCoursesReviewsLeavedReviewTableViewCell: UITableViewCell, Reusable {
    private lazy var cellView = UserCoursesReviewsLeavedReviewCellView()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.separatorBackgroundColor
        return view
    }()

    var onCoverClick: (() -> Void)? {
        get {
            self.cellView.onCoverClick
        }
        set {
            self.cellView.onCoverClick = newValue
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

    func configure(viewModel: UserCoursesReviewsItemViewModel) {
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
