import UIKit

final class CodeTextViewLayoutManager: NSLayoutManager {
    var lineNumberFont: UIFont
    var lineNumberTextColor: UIColor

    private var lastParagraphLocation = 0
    private var lastParagraphNumber = 0

    init(lineNumberFont: UIFont, lineNumberTextColor: UIColor) {
        self.lineNumberFont = lineNumberFont
        self.lineNumberTextColor = lineNumberTextColor
        super.init()
    }

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

        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.lineNumberFont,
            .foregroundColor: self.lineNumberTextColor
        ]

        var gutterRect = CGRect.zero
        var paragraphNumber = 0

        self.enumerateLineFragments(forGlyphRange: glyphsToShow) { (rect, _, _, glyphRange, _) in
            guard let textStorage = self.textStorage else {
                return
            }

            let characterRange = self.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            let paragraphRange = (textStorage.string as NSString).paragraphRange(for: characterRange)

            if characterRange.location == paragraphRange.location {
                gutterRect = CGRect(x: 0, y: rect.origin.y, width: 40, height: rect.height)
                gutterRect = gutterRect.offsetBy(dx: origin.x, dy: origin.y)

                paragraphNumber = self.getParagraph(for: characterRange)

                let lineNumber = "\(paragraphNumber + 1)"
                let lineNumberSize = lineNumber.size(withAttributes: attributes)

                let lineNumberRect = gutterRect.offsetBy(
                    dx: gutterRect.width - 4 - lineNumberSize.width,
                    dy: (gutterRect.height - lineNumberSize.height) / 2
                )

                lineNumber.draw(in: lineNumberRect, withAttributes: attributes)
            }
        }

        if NSMaxRange(glyphsToShow) > self.numberOfGlyphs {
            let lineNumber = "\(paragraphNumber + 2)"
            let lineNumberSize = lineNumber.size(withAttributes: attributes)

            gutterRect = gutterRect.offsetBy(dx: 0, dy: gutterRect.height)

            let lineNumberRect = gutterRect.offsetBy(
                dx: gutterRect.width - 4 - lineNumberSize.width,
                dy: (gutterRect.height - lineNumberSize.height) / 2
            )

            lineNumber.draw(in: lineNumberRect, withAttributes: attributes)
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
}
