import Atributika
import Foundation

protocol HTMLToAttributedStringConverterProtocol {
    func convert(htmlString: String) -> NSAttributedString
}

final class HTMLToAttributedStringConverter: HTMLToAttributedStringConverterProtocol {
    static let defaultTagTransformers: [TagTransformer] = [
        TagTransformer.brTransformer,
        TagTransformer(tagName: "p", tagType: .start, replaceValue: "\n"),
        TagTransformer(tagName: "p", tagType: .end, replaceValue: "\n")
    ]

    static func defaultTagStyles(fontSize: CGFloat) -> [Style] {
        [
            Style("b").font(.boldSystemFont(ofSize: fontSize)),
            Style("strong").font(.boldSystemFont(ofSize: fontSize)),
            Style("i").font(.italicSystemFont(ofSize: fontSize)),
            Style("em").font(.italicSystemFont(ofSize: fontSize)),
            Style("strike").strikethroughStyle(NSUnderlineStyle.single),
            Style("p").font(.systemFont(ofSize: fontSize))
        ]
    }

    private let font: UIFont
    private let tagStyles: [Style]
    private let tagTransformers: [TagTransformer]

    private var allStyle: Style { Style.font(self.font) }

    private var linkStyle: Style {
        Style("a")
            .foregroundColor(.blue, .normal)
            .foregroundColor(.stepikPrimaryText, .highlighted)
    }

    init(
        font: UIFont,
        tagStyles: [Style] = [],
        tagTransformers: [TagTransformer] = HTMLToAttributedStringConverter.defaultTagTransformers
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

    func convert(htmlString: String) -> NSAttributedString {
        htmlString
            .style(tags: self.tagStyles, transformers: self.tagTransformers)
            .styleLinks(self.linkStyle)
            .styleAll(self.allStyle)
            .attributedString
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
