import SnapKit
import UIKit

extension UserCoursesReviewsPossibleReviewTableViewCell {
    enum Appearance {
        static let separatorHeight: CGFloat = 4
        static let separatorBackgroundColor = UIColor.stepikOverlayOnSurfaceBackground
    }
}

final class UserCoursesReviewsPossibleReviewTableViewCell: UITableViewCell, Reusable {
    private lazy var cellView = UserCoursesReviewsPossibleReviewCellView()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.separatorBackgroundColor
        return view
    }()

    private var separatorHeightConstraint: Constraint?

    var shouldShowSeparator = true {
        didSet {
            if self.shouldShowSeparator != oldValue {
                self.separatorHeightConstraint?.update(
                    offset: self.shouldShowSeparator ? Appearance.separatorHeight : 0
                )
            }
        }
    }

    var onCoverClick: (() -> Void)? {
        get {
            self.cellView.onCoverClick
        }
        set {
            self.cellView.onCoverClick = newValue
        }
    }

    var onScoreDidChange: ((Int) -> Void)? {
        get {
            self.cellView.onScoreDidChange
        }
        set {
            self.cellView.onScoreDidChange = newValue
        }
    }

    var onActionButtonClick: (() -> Void)? {
        get {
            self.cellView.onActionButtonClick
        }
        set {
            self.cellView.onActionButtonClick = newValue
        }
    }

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

        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        self.cellView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.top.equalTo(self.cellView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
            self.separatorHeightConstraint = make.height.equalTo(Appearance.separatorHeight).constraint
        }
    }
}
