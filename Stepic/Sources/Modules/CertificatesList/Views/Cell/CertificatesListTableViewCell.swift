import UIKit

extension CertificatesListTableViewCell {
    enum Appearance {
        static let cornerRadius: CGFloat = 16

        static let cellViewInsets = LayoutInsets.default
    }
}

final class CertificatesListTableViewCell: UITableViewCell, Reusable {
    private lazy var cellView = CertificatesListCellView()

    var onCellViewClick: (() -> Void)?

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

    func configure(viewModel: CertificatesListItemViewModel) {
        self.cellView.configure(viewModel: viewModel)
    }

    private func setupSubview() {
        self.cellView.layer.cornerRadius = Appearance.cornerRadius
        self.cellView.layer.masksToBounds = true

        self.selectionStyle = .none
        self.cellView.addTarget(self, action: #selector(self.cellViewClicked), for: .touchUpInside)

        self.contentView.addSubview(self.cellView)

        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        self.cellView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Appearance.cellViewInsets.edgeInsets)
            make.bottom.equalToSuperview()
        }
    }

    @objc
    private func cellViewClicked() {
        self.onCellViewClick?()
    }
}
