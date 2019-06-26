import Foundation
import Regex

protocol ContentProcessingRule: class {
    func process(content: String) -> String
}

class BaseHTMLExtractionRule: ContentProcessingRule {
    fileprivate let extractorType: HTMLExtractorProtocol.Type

    init(extractorType: HTMLExtractorProtocol.Type) {
        self.extractorType = extractorType
    }

    /// Just return argument back
    func process(content: String) -> String {
        return content
    }
}

/// Add default protocol to all protocol relative paths, e.g replace "//site.com" with "http://site.com"
final class FixRelativeProtocolURLsRule: ContentProcessingRule {
    func process(content: String) -> String {
        return content.replacingOccurrences(of: "src=\"//", with: "src=\"http://")
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

        return "\(StepicApplicationsInfo.stepicURL)\(link)"
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

            content = content.replacingOccurrences(of: image, with: replacedImage)
        }
        return content
    }
}
