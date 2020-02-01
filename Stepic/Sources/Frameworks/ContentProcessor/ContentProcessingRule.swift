import Foundation
import Regex

protocol ContentProcessingRule: AnyObject {
    func process(content: String) -> String
}

class BaseHTMLExtractionRule: ContentProcessingRule {
    fileprivate let extractorType: HTMLExtractorProtocol.Type

    init(extractorType: HTMLExtractorProtocol.Type) {
        self.extractorType = extractorType
    }

    /// Just return argument back
    func process(content: String) -> String { content }
}

/// Add default protocol to all protocol relative paths, e.g replace "//site.com" with "http://site.com"
final class FixRelativeProtocolURLsRule: ContentProcessingRule {
    func process(content: String) -> String {
        content.replacingOccurrences(of: "src=\"//", with: "src=\"http://")
    }
}

/// Add Stepik domain to all relative paths, e.g replace "/content" with "http://stepik.org/content"
final class AddStepikSiteForRelativeURLsRule: BaseHTMLExtractionRule {
    override func process(content: String) -> String {
        let links = self.extractorType.extractAllTagsAttribute(tag: "a", attribute: "href", from: content)
            + self.extractorType.extractAllTagsAttribute(tag: "img", attribute: "src", from: content)

        var content = content
        for link in Array(Set(links)) {
            let wrappedLink = self.wrapLinkIfNeeded(link)
            if wrappedLink != link {
                content = content.replacingOccurrences(of: "\"\(link)", with: "\"\(wrappedLink)")
            }
        }

        return content
    }

    private func wrapLinkIfNeeded(_ link: String) -> String {
        guard link.first == "/" else {
            return link
        }

        if link.prefix(2) == "//" {
            // Protocol relative URL
            return link
        }

        return "\(StepikApplicationsInfo.stepicURL)\(link)"
    }
}

/// Remove image fixed height
final class RemoveImageFixedHeightRule: BaseHTMLExtractionRule {
    override func process(content: String) -> String {
        var content = content

        let images = self.extractorType.extractAllTags(tag: "img", from: content)
        for image in images {
            var replacedImage = image
            if let regex = try? Regex(string: "(height=\"\\d+\")", options: [.ignoreCase]) {
                replacedImage.replaceFirst(matching: regex, with: "")
            }
            replacedImage = replacedImage.condenseWhitespace()

            content = content.replacingOccurrences(of: image, with: replacedImage)
        }
        return content
    }
}

final class ReplaceImageSourceWithBase64: BaseHTMLExtractionRule {
    private let base64EncodedStringByImageURL: [URL: String]

    init(base64EncodedStringByImageURL: [URL: String], extractorType: HTMLExtractorProtocol.Type) {
        self.base64EncodedStringByImageURL = base64EncodedStringByImageURL
        super.init(extractorType: extractorType)
    }

    override func process(content: String) -> String {
        var content = content

        let images = self.extractorType.extractAllTags(tag: "img", from: content)
        let urlStrings = self.extractorType.extractAllTagsAttribute(tag: "img", attribute: "src", from: content)

        for (image, urlString) in zip(images, urlStrings) {
            guard let imageURL = URL(string: urlString),
                  let base64EncodedString = self.base64EncodedStringByImageURL[imageURL] else {
                continue
            }

            var replacedImage = image

            if let regex = try? Regex(string: "(src=\".*\")", options: [.ignoreCase]) {
                replacedImage.replaceFirst(
                    matching: regex,
                    with: "src=\"data:image/jpg;base64, \(base64EncodedString)\""
                )
            }
            replacedImage = replacedImage.condenseWhitespace()

            content = content.replacingOccurrences(of: image, with: replacedImage)
        }

        return content
    }
}

private extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
