import SnapKit
import UIKit

final class TableInputTextView: UITextView {
    private enum Appearance {
        static let defaultFont = UIFont.systemFont(ofSize: 17)
        static let textInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 16)
        static let minLinesInHeight = 4
    }

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = self.placeholderColor
        label.font = Appearance.defaultFont
        return label
    }()

    private var minHeight: CGFloat {
        return (self.font?.pointSize ?? 0) * CGFloat(Appearance.minLinesInHeight)
            + Appearance.textInsets.top
            + Appearance.textInsets.bottom
    }

    var maxTextLength: Int?

    // swiftlint:disable:next implicitly_unwrapped_optional
    override var text: String! {
        didSet {
            self.placeholderLabel.isHidden = !self.text.isEmpty
        }
    }

    var placeholder: String? {
        get {
            return self.placeholderLabel.text
        }
        set {
            self.placeholderLabel.text = newValue
        }
    }

    var placeholderColor = UIColor.black.withAlphaComponent(0.4) {
        didSet {
            self.placeholderLabel.textColor = self.placeholderColor
        }
    }

    override var font: UIFont? {
        didSet {
            self.placeholderLabel.font = self.font

            self.snp.updateConstraints { make in
                make.height.greaterThanOrEqualTo(self.minHeight)
            }
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.registerForNotifications()
        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let preferredSize = self.placeholderLabel.sizeThatFits(
            CGSize(width: self.textContainer.size.width, height: CGFloat.greatestFiniteMagnitude)
        )
        self.placeholderLabel.frame = CGRect(
            origin: self.placeholderLabel.frame.origin,
            size: preferredSize
        )
    }

    private func setupView() {
        // To make paddings like in UILabel
        self.textContainer.lineFragmentPadding = 0
        self.textContainerInset = Appearance.textInsets

        self.isScrollEnabled = false

        self.font = Appearance.defaultFont

        self.addSubview(self.placeholderLabel)
        self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Appearance.textInsets.top)
            make.leading.equalToSuperview().offset(Appearance.textInsets.left)
        }

        self.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(self.minHeight)
        }
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textViewDidEndEditing),
            name: Foundation.Notification.Name.UITextViewTextDidEndEditing,
            object: self
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textViewDidChange),
            name: Foundation.Notification.Name.UITextViewTextDidChange,
            object: self
        )
    }

    @objc
    private func textViewDidChange() {
        if let maxTextLength = self.maxTextLength {
            self.text = String(self.text.prefix(maxTextLength))
        }
    }

    @objc
    private func textViewDidEndEditing() {
        self.text = self.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
