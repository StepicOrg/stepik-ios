import UIKit

extension CodeTextViewLayoutManager {
    struct Appearance {
        var lineSpacing: CGFloat = 1.2
        var gutterWidth: CGFloat = 24.0

        var lineNumberFont = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
        var lineNumberTextColor = UIColor.stepikAccentAlpha50
        let lineNumberInsets = LayoutInsets(right: 4)

        var currentLineNumberTextColor = UIColor.stepikAccent
        var currentLineColor = UIColor.stepikAccentAlpha25
        var currentLineWidth: CGFloat = 24.0
    }
}

final class CodeTextViewLayoutManager: NSLayoutManager {
    var appearance: Appearance

    private var lineNumberTextAttributes: [NSAttributedString.Key: Any] {
        [
            .font: self.appearance.lineNumberFont,
            .foregroundColor: self.appearance.lineNumberTextColor
        ]
    }

    private var lastParagraphLocation = 0
    private var lastParagraphNumber = 0

    var selectedRange: NSRange?
    var shouldHighlightCurrentLine = true

    override init() {
        self.appearance = Appearance()
        super.init()
    }

    init(appearance: Appearance) {
        self.appearance = appearance
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func processEditing(
        for textStorage: NSTextStorage,
        edited editMask: NSTextStorage.EditActions,
        range newCharRange: NSRange,
        changeInLength delta: Int,
        invalidatedRange invalidatedCharRange: NSRange
    ) {
        super.processEditing(
            for: textStorage,
            edited: editMask,
            range: newCharRange,
            changeInLength: delta,
            invalidatedRange: invalidatedCharRange
        )

        if invalidatedCharRange.location < self.lastParagraphLocation {
            self.lastParagraphLocation = 0
            self.lastParagraphNumber = 0
        }
    }

    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)

        var gutterRect = CGRect.zero
        var paragraphNumber = 0

        self.enumerateLineFragments(forGlyphRange: glyphsToShow) { (rect, usedRect, _, glyphRange, _) in
            guard let textStorage = self.textStorage else {
                return
            }

            let characterRange = self.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            let paragraphRange = (textStorage.string as NSString).paragraphRange(for: characterRange)

            if self.shouldHighlightParagraphRange(paragraphRange) {
                self.highlightParagraphRange(paragraphRange, inUsedRect: usedRect, at: origin)
            }

            if characterRange.location == paragraphRange.location {
                gutterRect = CGRect(x: 0, y: rect.origin.y, width: self.appearance.gutterWidth, height: rect.height)
                gutterRect = gutterRect.offsetBy(dx: origin.x, dy: origin.y)

                paragraphNumber = self.getParagraph(for: characterRange)

                let attributes = self.lineNumberTextAttributesForParagraphRange(paragraphRange)
                let lineNumber = "\(paragraphNumber + 1)"
                let lineNumberSize = lineNumber.size(withAttributes: attributes)

                let lineNumberRect = gutterRect.offsetBy(
                    dx: gutterRect.width - self.appearance.lineNumberInsets.right - lineNumberSize.width,
                    dy: (gutterRect.height - lineNumberSize.height - self.appearance.lineSpacing) / 2
                )

                lineNumber.draw(in: lineNumberRect, withAttributes: attributes)
            }
        }

        guard let textStorage = self.textStorage else {
            return
        }

        //  Deal with the special case of an empty last line where enumerateLineFragmentsForGlyphRange has no line
        //  fragments to draw.
        if textStorage.string.isEmpty || textStorage.string.hasSuffix("\n") {
            let lineNumber = "\(paragraphNumber + 2)"
            let lineNumberSize = lineNumber.size(withAttributes: self.lineNumberTextAttributes)

            gutterRect = gutterRect.offsetBy(dx: 0.0, dy: gutterRect.height)
            let lineNumberRect = gutterRect.offsetBy(
                dx: gutterRect.width - self.appearance.lineNumberInsets.right - lineNumberSize.width,
                dy: 0
            )

            lineNumber.draw(in: lineNumberRect, withAttributes: self.lineNumberTextAttributes)
        }
    }

    private func getParagraph(for characterRange: NSRange) -> Int {
        if characterRange.location == self.lastParagraphLocation {
            return self.lastParagraphNumber
        } else if characterRange.location < self.lastParagraphLocation {
            guard let textStorage = self.textStorage else {
                return self.lastParagraphNumber
            }

            let characterContents = textStorage.string as NSString
            var paragraphNumber = self.lastParagraphNumber

            characterContents.enumerateSubstrings(
                in: NSRange(
                    location: characterRange.location,
                    length: self.lastParagraphLocation - characterRange.location
                ),
                options: [.byParagraphs, .substringNotRequired, .reverse],
                using: { (_, _, enclosingRange, stop) in
                    if enclosingRange.location <= characterRange.location {
                        stop.pointee = true
                    }
                    paragraphNumber -= 1
                }
            )

            self.lastParagraphLocation = characterRange.location
            self.lastParagraphNumber = paragraphNumber

            return paragraphNumber
        } else {
            guard let textStorage = self.textStorage else {
                return self.lastParagraphNumber
            }

            let characterContents = textStorage.string as NSString
            var paragraphNumber = self.lastParagraphNumber

            characterContents.enumerateSubstrings(
                in: NSRange(
                    location: self.lastParagraphLocation,
                    length: characterRange.location - self.lastParagraphLocation
                ),
                options: [.byParagraphs, .substringNotRequired],
                using: { (_, _, enclosingRange, stop) in
                    if enclosingRange.location >= characterRange.location {
                        stop.pointee = true
                    }
                    paragraphNumber += 1
                }
            )

            self.lastParagraphLocation = characterRange.location
            self.lastParagraphNumber = paragraphNumber

            return paragraphNumber
        }
    }

    private func lineNumberTextAttributesForParagraphRange(_ paragraphRange: NSRange) -> [NSAttributedString.Key: Any] {
        self.shouldHighlightParagraphRange(paragraphRange)
            ? [.font: self.appearance.lineNumberFont, .foregroundColor: self.appearance.currentLineNumberTextColor]
            : self.lineNumberTextAttributes
    }

    private func shouldHighlightParagraphRange(_ paragraphRange: NSRange) -> Bool {
        guard self.shouldHighlightCurrentLine, let selectedRange = self.selectedRange else {
            return false
        }
        return NSLocationInRange(selectedRange.location, paragraphRange)
    }

    private func highlightParagraphRange(_ paragraphRange: NSRange, inUsedRect usedRect: CGRect, at origin: CGPoint) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        var cursorRect = CGRect(
            x: 0,
            y: usedRect.origin.y,
            width: self.appearance.currentLineWidth,
            height: usedRect.height
        )
        cursorRect = cursorRect.offsetBy(dx: origin.x, dy: origin.y)

        context.setFillColor(self.appearance.currentLineColor.cgColor)
        context.fill(cursorRect)
    }
}
