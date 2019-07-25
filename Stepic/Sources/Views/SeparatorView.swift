import SnapKit
import UIKit

extension SeparatorView {
    struct Appearance {
        /// UITableView's default separator height.
        let height: CGFloat = 1.0
        /// UITableView's default separator color.
        let color = UIColor(hex: 0xC8C7CC)
    }
}

/// View to make separator consistent appearance.
final class SeparatorView: UIView {
    let appearance: Appearance

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.appearance.height / UIScreen.main.scale)
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)
        self.setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.backgroundColor = self.appearance.color
    }
}
