import SnapKit
import UIKit

class SettingsTableViewCell<T: UIView>: UITableViewCell, Reusable {
    private let elementViewLeftInset: CGFloat = 16

    lazy var elementView = T()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        self.contentView.addSubview(self.elementView)
        self.elementView.translatesAutoresizingMaskIntoConstraints = false
        self.elementView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.elementViewLeftInset)
            make.top.bottom.trailing.equalToSuperview()
        }
    }
}
