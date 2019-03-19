import UIKit

class TableInputTextField: UITextField {
    private enum Appearance {
        static let defaultFont = UIFont.systemFont(ofSize: 17)
        static let textAreaInsets = UIEdgeInsets(top: 1, left: 8, bottom: 0, right: 0)
    }

    private lazy var pinnedPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.font = Appearance.defaultFont
        label.textColor = self.placeholderColor
        return label
    }()

    var placeholderColor = UIColor.black.withAlphaComponent(0.4)

    var shouldAlwaysShowPlaceholder = false {
        didSet {
            self.updateLeftViewMode()
        }
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
        if self.shouldAlwaysShowPlaceholder {
            return CGRect(
                origin: CGPoint(x: rect.origin.x + Appearance.textAreaInsets.left, y: Appearance.textAreaInsets.top),
                size: CGSize(width: rect.size.width, height: bounds.height)
            )
        } else {
            return rect
        }
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        if self.shouldAlwaysShowPlaceholder {
            return CGRect(
                origin: CGPoint(x: rect.origin.x + Appearance.textAreaInsets.left, y: Appearance.textAreaInsets.top),
                size: CGSize(width: rect.size.width, height: bounds.height)
            )
        } else {
            return rect
        }
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
