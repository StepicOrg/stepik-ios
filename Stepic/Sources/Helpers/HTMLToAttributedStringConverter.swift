import Atributika
import Foundation

protocol HTMLToAttributedStringConverterProtocol {
    func convertToAttributedText(htmlString: String) -> AttributedTextProtocol
    func convertToAttributedString(htmlString: String) -> NSAttributedString
}

final class HTMLToAttributedStringConverter: HTMLToAttributedStringConverterProtocol {
    static let defaultTagTransformers: [TagTransformer] = [
        TagTransformer.brTransformer,
        TagTransformer(tagName: "p", tagType: .start, replaceValue: "\n"),
        TagTransformer(tagName: "p", tagType: .end, replaceValue: "\n")
    ]

    static let defaultLinkStyle = Style("a")
        .foregroundColor(.stepikLightBlue, .normal)
        .foregroundColor(.stepikPrimaryText, .highlighted)

    static func defaultTagStyles(fontSize: CGFloat) -> [Style] {
        [
            Style("b").font(.boldSystemFont(ofSize: fontSize)),
            Style("strong").font(.boldSystemFont(ofSize: fontSize)),
            Style("i").font(.italicSystemFont(ofSize: fontSize)),
            Style("em").font(.italicSystemFont(ofSize: fontSize)),
            Style("strike").strikethroughStyle(NSUnderlineStyle.single),
            Style("p").font(.systemFont(ofSize: fontSize)),
            Self.defaultLinkStyle
        ]
    }

    private let font: UIFont
    private let tagStyles: [Style]
    private let tagTransformers: [TagTransformer]

    private var allStyle: Style { Style.font(self.font) }

    init(
        font: UIFont,
        tagStyles: [Style] = [],
        tagTransformers: [TagTransformer] = []
    ) {
        let defaultStyles = Self.defaultTagStyles(fontSize: font.pointSize)
        let finalStyles = tagStyles.isEmpty
            ? defaultStyles
            : (
                tagStyles + defaultStyles.filter { defaultStyle in
                    !tagStyles.contains { $0.name == defaultStyle.name }
                }
        )

        self.font = font
        self.tagStyles = finalStyles
        self.tagTransformers = tagTransformers
    }

    func convertToAttributedText(htmlString: String) -> AttributedTextProtocol {
        htmlString
            .style(tags: self.tagStyles, transformers: self.tagTransformers)
            .styleLinks(Self.defaultLinkStyle)
            .styleAll(self.allStyle)
    }

    func convertToAttributedString(htmlString: String) -> NSAttributedString {
        guard let attributedText = self.convertToAttributedText(htmlString: htmlString) as? AttributedText else {
            return NSAttributedString()
        }

        return attributedText
            .attributedString
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
