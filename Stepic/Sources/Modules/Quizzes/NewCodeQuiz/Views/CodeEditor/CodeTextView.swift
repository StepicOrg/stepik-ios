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

    var language: String? {
        didSet {
            if self.language != oldValue,
               let textStorage = self.layoutManager.textStorage as? CodeAttributedString {
                textStorage.language = self.language
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
        if let context = UIGraphicsGetCurrentContext() {
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
        }

        super.draw(rect)
    }

    func updateTheme(name: String, font: UIFont) {
        guard let textStorage = self.layoutManager.textStorage as? CodeAttributedString else {
            return
        }

        textStorage.highlightr.setTheme(to: name)

        if let theme = textStorage.highlightr.theme {
            theme.setCodeFont(font)
            textStorage.highlightr.theme = theme

            self.backgroundColor = textStorage.highlightr.theme.themeBackgroundColor
        }
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

    func layoutManager(
        _ layoutManager: NSLayoutManager,
        lineSpacingAfterGlyphAt glyphIndex: Int,
        withProposedLineFragmentRect rect: CGRect
    ) -> CGFloat {
        return self.appearance.lineSpacing
    }
}
