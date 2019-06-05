import Foundation
import Kanna

protocol HTMLExtractorProtocol: class {
    static func extractAllTagsAttribute(tag: String, attribute: String, from text: String) -> [String]
    static func extractAllTagsContent(tag: String, from text: String) -> [String]
    static func extractAllTags(tag: String, from text: String) -> [String]
}

final class HTMLExtractor: HTMLExtractorProtocol {
    private static func makeDocumentDOM(from text: String) -> HTMLDocument? {
        return try? Kanna.HTML(html: text, encoding: String.Encoding.utf8)
    }

    static func extractAllTagsAttribute(tag: String, attribute: String, from text: String) -> [String] {
        guard let documentDOM = HTMLExtractor.makeDocumentDOM(from: text) else {
            return []
        }

        return documentDOM.css(tag).compactMap { $0[attribute] }
    }

    static func extractAllTagsContent(tag: String, from text: String) -> [String] {
        guard let documentDOM = HTMLExtractor.makeDocumentDOM(from: text) else {
            return []
        }

        return documentDOM.css(tag).compactMap { $0.text }
    }

    static func extractAllTags(tag: String, from text: String) -> [String] {
        guard let documentDOM = HTMLExtractor.makeDocumentDOM(from: text) else {
            return []
        }

        return documentDOM.css(tag).compactMap { $0.toHTML }
    }
}
