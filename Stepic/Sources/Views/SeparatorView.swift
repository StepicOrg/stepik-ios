import SnapKit
import UIKit

// View to make separator consistent appearance
extension SeparatorView {
    struct Appearance {
        let height: CGFloat = 0.5
        let color = UIColor(hex: 0xD1D1D6)
    }
}

final class SeparatorView: UIView {
    let appearance: Appearance

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 1 / UIScreen.main.scale)
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
