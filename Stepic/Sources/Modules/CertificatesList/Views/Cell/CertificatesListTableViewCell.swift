import UIKit

extension CertificatesListTableViewCell {
    enum Appearance {
        static let cornerRadius: CGFloat = 16

        static let shadowColor = UIColor.black
        static let shadowOffset = CGSize(width: 0, height: 0)
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Float = 0.1

        static let cellViewInsets = LayoutInsets.default
    }
}

final class CertificatesListTableViewCell: UITableViewCell, Reusable {
    private lazy var cellView = CertificatesListCellView()

    override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()

        if self.cellView.superview == nil {
            self.setupSubview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.cellView.layer.cornerRadius = Appearance.cornerRadius

        self.cellView.layer.shadowColor = Appearance.shadowColor.cgColor
        self.cellView.layer.shadowOffset = Appearance.shadowOffset
        self.cellView.layer.shadowRadius = Appearance.shadowRadius
        self.cellView.layer.shadowOpacity = Appearance.shadowOpacity

        self.cellView.layer.masksToBounds = false
        self.cellView.layer.shadowPath = UIBezierPath(
            roundedRect: self.cellView.bounds,
            cornerRadius: Appearance.cornerRadius
        ).cgPath

        self.cellView.layer.shouldRasterize = true
        self.cellView.layer.rasterizationScale = UIScreen.main.scale
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellView.configure(viewModel: nil)
    }

    func configure(viewModel: CertificatesListItemViewModel) {
        self.cellView.configure(viewModel: viewModel)
    }

    private func setupSubview() {
        self.contentView.addSubview(self.cellView)

        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        self.cellView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Appearance.cellViewInsets.edgeInsets)
            make.bottom.equalToSuperview()
        }
    }
}
