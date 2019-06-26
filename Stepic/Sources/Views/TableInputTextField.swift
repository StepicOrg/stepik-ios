import UIKit

class TableInputTextField: UITextField {
    private enum Appearance {
        static let defaultFont = UIFont.systemFont(ofSize: 17)
        static let textAreaInsets = UIEdgeInsets(top: 1, left: 12, bottom: 0, right: 12)
    }

    private lazy var pinnedPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.font = Appearance.defaultFont
        label.textColor = self.placeholderColor
        return label
    }()

    private var additionalPlaceholderRightPadding: CGFloat {
        if let width = self.placeholderMinimalWidth {
            return max(0, width - self.placeholderWidth)
        }
        return 0
    }

    var placeholderColor = UIColor.black.withAlphaComponent(0.4)

    var textInsets = Appearance.textAreaInsets {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var shouldAlwaysShowPlaceholder = false {
        didSet {
            self.updateLeftViewMode()
        }
    }

    var placeholderMinimalWidth: CGFloat? {
        didSet {
            if self.placeholderMinimalWidth != nil {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }

    var placeholderWidth: CGFloat {
        return self.pinnedPlaceholderLabel.frame.width
    }

    override var font: UIFont? {
        didSet {
            self.pinnedPlaceholderLabel.font = self.font
        }
    }

    override var placeholder: String? {
        didSet {
            self.attributedPlaceholder = NSAttributedString(
                string: self.placeholder ?? "",
                attributes: [.foregroundColor: self.placeholderColor]
            )
        }
    }

    override var attributedPlaceholder: NSAttributedString? {
        didSet {
            self.pinnedPlaceholderLabel.attributedText = self.attributedPlaceholder
            self.leftView?.sizeToFit()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        if self.shouldAlwaysShowPlaceholder {
            return .zero
        } else {
            return super.placeholderRect(forBounds: bounds)
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)

        return CGRect(
            origin: CGPoint(
                x: rect.origin.x
                    + (self.shouldAlwaysShowPlaceholder ? self.additionalPlaceholderRightPadding : 0)
                    + self.textInsets.left,
                y: self.textInsets.top
            ),
            size: CGSize(
                width: rect.size.width - self.textInsets.right - self.additionalPlaceholderRightPadding,
                height: bounds.height
            )
        )
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return CGRect(
            origin: CGPoint(
                x: rect.origin.x
                    + (self.shouldAlwaysShowPlaceholder ? self.additionalPlaceholderRightPadding : 0)
                    + self.textInsets.left,
                y: self.textInsets.top
            ),
            size: CGSize(
                width: rect.size.width - self.textInsets.right - self.additionalPlaceholderRightPadding,
                height: bounds.height
            )
        )
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.leftViewRect(forBounds: bounds)
        if self.shouldAlwaysShowPlaceholder {
            return CGRect(
                origin: CGPoint(x: rect.origin.x, y: 0),
                size: CGSize(width: rect.size.width, height: bounds.height)
            )
        } else {
            return rect
        }
    }

    private func updateLeftViewMode() {
        if self.shouldAlwaysShowPlaceholder {
            self.leftViewMode = .always
        } else {
            self.leftViewMode = .never
        }
    }

    private func setupView() {
        self.contentVerticalAlignment = .center
        self.font = Appearance.defaultFont

        self.updateLeftViewMode()
        self.leftView = self.pinnedPlaceholderLabel
    }
}
