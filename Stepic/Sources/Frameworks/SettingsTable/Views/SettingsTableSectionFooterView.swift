import SnapKit
import UIKit

final class SettingsTableSectionFooterView: UITableViewHeaderFooterView, Reusable {
    enum Appearance {
        static let font = UIFont.systemFont(ofSize: 13)
        static let labelColor = UIColor(hex: 0x000000, alpha: 0.4)
        static let labelInsets = UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16)
    }

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Appearance.font
        label.textColor = Appearance.labelColor
        label.numberOfLines = 0
        return label
    }()

    var text: String? {
        didSet {
            self.descriptionLabel.text = self.text
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.descriptionLabel.superview == nil {
            self.contentView.addSubview(self.descriptionLabel)
            self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            self.descriptionLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(Appearance.labelInsets)
            }
        }
    }
}
