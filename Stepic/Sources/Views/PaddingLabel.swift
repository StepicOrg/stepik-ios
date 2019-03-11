import UIKit

final class PaddingLabel: UILabel {
    var padding: UIEdgeInsets = .zero {
        didSet {
            self.layoutIfNeeded()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, self.padding))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + self.padding.left + self.padding.right,
            height: size.height + self.padding.top + self.padding.bottom
        )
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = super.sizeThatFits(size)
        return CGSize(
            width: size.width + self.padding.left + self.padding.right,
            height: size.height + self.padding.top + self.padding.bottom
        )
    }
}
