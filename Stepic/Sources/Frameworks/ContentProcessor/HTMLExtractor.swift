import Foundation
import Kanna

protocol HTMLExtractorProtocol: class {
    static func extractAllATagLinks(from content: String) -> [(link: String, text: String)]
    static func extractAllIFrameTagSrcLinks(from content: String) -> [String]
    static func extractAllImageTagSrcLinks(from content: String) -> [String]
    static func extractAllCodeTagContents(from content: String) -> [String]
}

final class HTMLExtractor: HTMLExtractorProtocol {
    private static func makeDocumentDOM(from text: String) -> HTMLDocument? {
        return try? Kanna.HTML(html: text, encoding: String.Encoding.utf8)
    }

    static func extractAllATagLinks(from text: String) -> [(link: String, text: String)] {
        guard let documentDOM = HTMLExtractor.makeDocumentDOM(from: text) else {
            return []
        }

        let result: [(link: String, text: String)] = documentDOM.css("a").compactMap {
            if let link = $0["href"], let text = $0.text {
                return (link: link, text: text)
            }
            return nil
        }
        return result
    }

    static func extractAllIFrameTagSrcLinks(from text: String) -> [String] {
        guard let documentDOM = HTMLExtractor.makeDocumentDOM(from: text) else {
            return []
        }

        return documentDOM.css("iframe").compactMap { $0["src"] }
    }

    static func extractAllImageTagSrcLinks(from text: String) -> [String] {
        guard let documentDOM = HTMLExtractor.makeDocumentDOM(from: text) else {
            return []
        }

        return documentDOM.css("img").compactMap { $0["src"] }
    }

    static func extractAllCodeTagContents(from text: String) -> [String] {
        guard let documentDOM = HTMLExtractor.makeDocumentDOM(from: text) else {
            return []
        }

        return documentDOM.css("code").compactMap { $0.text }
    }
}
