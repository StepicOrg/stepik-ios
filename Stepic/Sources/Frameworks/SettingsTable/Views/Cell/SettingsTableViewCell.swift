import SnapKit
import UIKit

extension SettingsTableViewCell {
    struct Appearance {
        var unselectedBackgroundColor: UIColor?
        var selectedBackgroundColor: UIColor?
    }
}

class SettingsTableViewCell<T: UIView>: UITableViewCell, Reusable {
    private let elementViewLeftInset: CGFloat = 16

    lazy var elementView = T()

    var appearance = Appearance() {
        didSet {
            self.contentView.backgroundColor = self.appearance.unselectedBackgroundColor

            if let selectedBackgroundColor = self.appearance.selectedBackgroundColor {
                let backgroundView = UIView()
                backgroundView.backgroundColor = selectedBackgroundColor
                self.selectedBackgroundView = backgroundView
            } else {
                self.selectedBackgroundView = nil
            }
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        self.contentView.addSubview(self.elementView)
        self.elementView.translatesAutoresizingMaskIntoConstraints = false
        self.elementView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.elementViewLeftInset)
            make.top.bottom.trailing.equalToSuperview()
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.updateSelectedBackgroundColor(highlighted)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.updateSelectedBackgroundColor(selected)
    }

    private func updateSelectedBackgroundColor(_ selected: Bool) {
        if selected && self.appearance.selectedBackgroundColor != nil {
            self.contentView.backgroundColor = nil
        } else {
            self.contentView.backgroundColor = self.appearance.unselectedBackgroundColor
        }
    }
}
