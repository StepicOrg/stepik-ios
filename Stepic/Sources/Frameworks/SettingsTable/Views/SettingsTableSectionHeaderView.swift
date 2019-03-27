import SnapKit
import UIKit

final class SettingsTableSectionHeaderView: UITableViewHeaderFooterView, Reusable {
    enum Appearance {
        static let font = UIFont.systemFont(ofSize: 18, weight: .bold)
        static let labelInsets = UIEdgeInsets(top: 20, left: 16, bottom: 8, right: 16)
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Appearance.font
        return label
    }()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.titleLabel.superview == nil {
            self.contentView.addSubview(self.titleLabel)
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.titleLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(Appearance.labelInsets)
            }
        }
    }
}
