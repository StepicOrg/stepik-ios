import SnapKit
import UIKit

final class CourseSearchResultTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let separatorHeight: CGFloat = 4
        static let separatorBackgroundColor = UIColor.stepikOverlayOnSurfaceBackground
    }

    private lazy var cellView = CourseSearchResultTableCellView()

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

    var onCommentClick: (() -> Void)? {
        get {
            self.cellView.onCommentClick
        }
        set {
            self.cellView.onCommentClick = newValue
        }
    }

    var onCommentUserAvatarClick: (() -> Void)? {
        get {
            self.cellView.onCommentUserAvatarClick
        }
        set {
            self.cellView.onCommentUserAvatarClick = newValue
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

    func configure(viewModel: CourseSearchResultViewModel) {
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
            make.height.equalTo(Appearance.separatorHeight)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
            make.top.equalTo(self.cellView.snp.bottom)
        }
    }
}
