import Highlightr
import UIKit

final class CodeTextView: UITextView {
    private static let lineNumberGutterWidth: CGFloat = 40

    // swiftlint:disable:next force_cast
    private lazy var codeTextViewLayoutManager = self.layoutManager as! CodeTextViewLayoutManager

    var language: String? {
        didSet {
            guard self.language != oldValue,
                  let language = self.language,
                  let codeAttributedString = self.codeTextViewLayoutManager.textStorage as? CodeAttributedString else {
                return
            }

            codeAttributedString.language = CodeLanguage(rawValue: language)?.highlightr
        }
    }

    var lineNumberFont: UIFont {
        get {
            return self.codeTextViewLayoutManager.lineNumberFont
        }
        set {
            if self.codeTextViewLayoutManager.lineNumberFont != newValue {
                self.codeTextViewLayoutManager.lineNumberFont = newValue
                self.setNeedsDisplay()
            }
        }
    }

    var lineNumberTextColor: UIColor {
        get {
            return self.codeTextViewLayoutManager.lineNumberTextColor
        }
        set {
            if self.codeTextViewLayoutManager.lineNumberTextColor != newValue {
                self.codeTextViewLayoutManager.lineNumberTextColor = newValue
                self.setNeedsDisplay()
            }
        }
    }

    var lineNumberBackgroundColor = UIColor.gray {
        didSet {
            if self.lineNumberBackgroundColor != oldValue {
                self.setNeedsDisplay()
            }
        }
    }

    var lineNumberBorderColor = UIColor.darkGray {
        didSet {
            if self.lineNumberBorderColor != oldValue {
                self.setNeedsDisplay()
            }
        }
    }

    init(lineNumberFont: UIFont = .systemFont(ofSize: 10), lineNumberTextColor: UIColor = .white) {
        let textStorage = CodeAttributedString()
        textStorage.language = self.language

        let layoutManager = CodeTextViewLayoutManager(
            lineNumberFont: lineNumberFont,
            lineNumberTextColor: lineNumberTextColor
        )
        let textContainer = NSTextContainer()
        textContainer.widthTracksTextView = true
        // Exclude (move right) the line number gutter from the display area of the text container.
        textContainer.exclusionPaths = [
            UIBezierPath(
                rect: CGRect(
                    origin: .zero,
                    size: CGSize(width: CodeTextView.lineNumberGutterWidth, height: CGFloat.greatestFiniteMagnitude)
                )
            )
        ]

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        super.init(frame: .zero, textContainer: textContainer)

        layoutManager.delegate = self
        self.contentMode = .redraw
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            let bounds = self.bounds

            context.setFillColor(self.lineNumberBackgroundColor.cgColor)
            let fillRect = CGRect(
                origin: bounds.origin,
                size: CGSize(width: CodeTextView.lineNumberGutterWidth, height: bounds.height)
            )
            context.fill(fillRect)

            context.setStrokeColor(self.lineNumberBorderColor.cgColor)
            context.setLineWidth(0.5)
            let strokeRect = CGRect(x: bounds.origin.x + 39.5, y: bounds.origin.y, width: 0.5, height: bounds.height)
            context.stroke(strokeRect)
        }

        super.draw(rect)
    }
}

extension CodeTextView: NSLayoutManagerDelegate {
    func layoutManager(
        _ layoutManager: NSLayoutManager,
        didCompleteLayoutFor textContainer: NSTextContainer?,
        atEnd layoutFinishedFlag: Bool
    ) {
        if layoutFinishedFlag {
            self.setNeedsDisplay()
        }
    }
}
