import Highlightr
import UIKit

extension CodeTextView {
    struct Appearance {
        let gutterWidth: CGFloat = 24
        let gutterBackgroundColor = UIColor(hex: 0xF6F6F6)
        let gutterBorderColor = UIColor(hex: 0xC8C7CC)
        let gutterBorderWidth: CGFloat = 0.5

        let lineNumberFont = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
        let lineNumberTextColor = UIColor.mainDark.withAlphaComponent(0.5)
        let lineSpacing: CGFloat = 1.2
    }
}

final class CodeTextView: UITextView {
    let appearance: Appearance

    private lazy var codeTextViewLayoutManager = self.layoutManager as? CodeTextViewLayoutManager
    private lazy var codeAttributedString = self.textStorage as? CodeAttributedString

    var language: String? {
        didSet {
            guard self.language != oldValue,
                  let codeAttributedString = self.codeAttributedString else {
                return
            }

            codeAttributedString.language = self.language
        }
    }

    var shouldHighlightCurrentLine = true {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override var selectedTextRange: UITextRange? {
        didSet {
            if self.shouldHighlightCurrentLine {
                self.setNeedsDisplay()
            }
        }
    }

    override var selectedRange: NSRange {
        didSet {
            if self.shouldHighlightCurrentLine {
                self.setNeedsDisplay()
            }
        }
    }

    init(appearance: Appearance = Appearance()) {
        self.appearance = appearance

        let textStorage = CodeAttributedString()
        textStorage.language = self.language

        let layoutManager = CodeTextViewLayoutManager(
            appearance: .init(
                lineSpacing: self.appearance.lineSpacing,
                gutterWidth: self.appearance.gutterWidth,
                lineNumberFont: self.appearance.lineNumberFont,
                lineNumberTextColor: self.appearance.lineNumberTextColor
            )
        )

        let textContainer = NSTextContainer()
        textContainer.widthTracksTextView = true
        // Exclude (move right) the line number gutter from the display area of the text container.
        textContainer.exclusionPaths = [
            UIBezierPath(
                rect: CGRect(
                    origin: .zero,
                    size: CGSize(width: appearance.gutterWidth, height: CGFloat.greatestFiniteMagnitude)
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
        defer {
            super.draw(rect)
        }

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let bounds = self.bounds

        context.setFillColor(self.appearance.gutterBackgroundColor.cgColor)
        let fillRect = CGRect(
            origin: bounds.origin,
            size: CGSize(width: self.appearance.gutterWidth, height: bounds.height)
        )
        context.fill(fillRect)

        context.setStrokeColor(self.appearance.gutterBorderColor.cgColor)
        context.setLineWidth(self.appearance.gutterBorderWidth)
        let strokeRect = CGRect(
            x: bounds.origin.x + self.appearance.gutterWidth - self.appearance.gutterBorderWidth,
            y: bounds.origin.y,
            width: self.appearance.gutterBorderWidth,
            height: bounds.height
        )
        context.stroke(strokeRect)

        self.invalidateDisplayOfCurrentLine()
    }

    func updateTheme(name: String, font: UIFont) {
        guard let codeAttributedString = self.codeAttributedString else {
            return
        }

        codeAttributedString.highlightr.setTheme(to: name)

        if let highlightrTheme = codeAttributedString.highlightr.theme {
            highlightrTheme.setCodeFont(font)
            codeAttributedString.highlightr.theme = highlightrTheme

            self.backgroundColor = codeAttributedString.highlightr.theme.themeBackgroundColor
        }
    }

    private func invalidateDisplayOfCurrentLine() {
        guard let codeTextViewLayoutManager = self.codeTextViewLayoutManager else {
            return
        }

        guard self.shouldHighlightCurrentLine else {
            codeTextViewLayoutManager.shouldHighlightCurrentLine = false
            codeTextViewLayoutManager.selectedRange = nil
            return
        }

        codeTextViewLayoutManager.shouldHighlightCurrentLine = true
        codeTextViewLayoutManager.selectedRange = self.selectedRange

        let textStorageString = self.textStorage.string as NSString

        var glyphRange = textStorageString.paragraphRange(for: self.selectedRange)
        glyphRange = codeTextViewLayoutManager.glyphRange(forCharacterRange: glyphRange, actualCharacterRange: nil)

        codeTextViewLayoutManager.selectedRange = glyphRange
        codeTextViewLayoutManager.invalidateDisplay(forGlyphRange: glyphRange)
    }
}

// MARK: - CodeTextView: NSLayoutManagerDelegate -

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

    func layoutManager(
        _ layoutManager: NSLayoutManager,
        lineSpacingAfterGlyphAt glyphIndex: Int,
        withProposedLineFragmentRect rect: CGRect
    ) -> CGFloat {
        self.appearance.lineSpacing
    }
}
