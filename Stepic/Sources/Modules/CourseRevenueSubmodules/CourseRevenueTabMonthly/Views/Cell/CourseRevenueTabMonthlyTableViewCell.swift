import UIKit

final class CourseRevenueTabMonthlyTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let separatorHeight: CGFloat = 1
        static let separatorColor = UIColor.dynamic(
            light: .onSurface.withAlphaComponent(0.04),
            dark: .stepikSeparator
        )
    }

    private lazy var cellView = CourseRevenueTabMonthlyCellView()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.separatorColor
        return view
    }()

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

    func configure(viewModel: CourseRevenueTabMonthlyViewModel) {
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
