import UIKit

final class CourseRevenueTabPurchasesTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let separatorHeight: CGFloat = 1
        static let separatorColor = UIColor.stepikOverlayOnSurfaceBackground
    }

    private lazy var cellView = CourseRevenueTabPurchasesCellView()
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.separatorColor
        return view
    }()

    var onTitleLabelTapped: (() -> Void)? {
        get {
            self.cellView.onTitleLabelTapped
        }
        set {
            self.cellView.onTitleLabelTapped = newValue
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

    func configure(viewModel: CourseRevenueTabPurchasesViewModel) {
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
            make.height.equalTo(Appearance.separatorHeight)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
            make.top.equalTo(self.cellView.snp.bottom)
        }
    }
}
